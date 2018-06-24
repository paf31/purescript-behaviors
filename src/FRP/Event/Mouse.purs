module FRP.Event.Mouse
  ( Mouse
  , getMouse
  , disposeMouse
  , move
  , down
  , up
  , withPosition
  , withButtons
  ) where

import Prelude

import Data.Compactable (compact)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Data.Newtype (wrap)
import Data.Set as Set
import Effect (Effect)
import Effect.Ref as Ref
import FRP.Event (Event, makeEvent, subscribe)
import Web.Event.EventTarget (addEventListener, eventListener, removeEventListener)
import Web.HTML (window)
import Web.HTML.Window (toEventTarget)
import Web.UIEvent.MouseEvent (button, clientX, clientY, fromEvent)

-- | A handle for creating events from the mouse position and buttons.
newtype Mouse = Mouse
  { position :: Ref.Ref (Maybe { x :: Int, y :: Int })
  , buttons :: Ref.Ref (Set.Set Int)
  , dispose :: Effect Unit
  }
  
-- | Get a handle for working with the mouse.
getMouse :: Effect Mouse
getMouse = do
  position <- Ref.new Nothing
  buttons <- Ref.new Set.empty
  target <- toEventTarget <$> window
  mouseMoveListener <- eventListener \e -> do
    fromEvent e # traverse_ \me ->
      Ref.write (Just { x: clientX me, y: clientY me }) position
  mouseDownListener <- eventListener \e -> do
    fromEvent e # traverse_ \me ->
      Ref.modify (Set.insert (button me)) buttons
  mouseUpListener <- eventListener \e -> do
    fromEvent e # traverse_ \me ->
      Ref.modify (Set.delete (button me)) buttons
  addEventListener (wrap "mousemove") mouseMoveListener false target
  addEventListener (wrap "mousedown") mouseDownListener false target
  addEventListener (wrap "mouseup") mouseUpListener false target
  let dispose = do
        removeEventListener (wrap "mousemove") mouseMoveListener false target
        removeEventListener (wrap "mousedown") mouseDownListener false target
        removeEventListener (wrap "mouseup") mouseUpListener false target
  pure (Mouse { position, buttons, dispose })

disposeMouse :: Mouse -> Effect Unit
disposeMouse (Mouse { dispose }) = dispose

-- | Create an `Event` which fires when the mouse moves
move :: Mouse -> Event { x :: Int, y :: Int }
move m = compact (_.pos <$> withPosition m (pure unit))

-- | Create an `Event` which fires when a mouse button is pressed
down :: Event Int
down = makeEvent \k -> do
  target <- toEventTarget <$> window
  mouseDownListener <- eventListener \e -> do
    fromEvent e # traverse_ \me ->
      k (button me)
  addEventListener (wrap "mousedown") mouseDownListener false target
  pure (removeEventListener (wrap "mousedown") mouseDownListener false target)

-- | Create an `Event` which fires when a mouse button is released
up :: Event Int
up = makeEvent \k -> do
  target <- toEventTarget <$> window
  mouseUpListener <- eventListener \e -> do
    fromEvent e # traverse_ \me ->
      k (button me)
  addEventListener (wrap "mouseup") mouseUpListener false target
  pure (removeEventListener (wrap "mouseup") mouseUpListener false target)

-- | Create an event which also returns the current mouse position.
withPosition
  :: forall a
   . Mouse
  -> Event a
  -> Event { value :: a, pos :: Maybe { x :: Int, y :: Int } }
withPosition (Mouse { position }) e = makeEvent \k ->
  e `subscribe` \value -> do
    pos <- Ref.read position
    k { value, pos }

-- | Create an event which also returns the current mouse buttons.
withButtons
  :: forall a
   . Mouse
  -> Event a
  -> Event { value :: a, buttons :: Set.Set Int }
withButtons (Mouse { buttons }) e = makeEvent \k ->
  e `subscribe` \value -> do
    buttonsValue <- Ref.read buttons
    k { value, buttons: buttonsValue }
