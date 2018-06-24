module FRP.Event.Keyboard
  ( Keyboard
  , getKeyboard
  , disposeKeyboard
  , down
  , up
  , withKeys
  ) where

import Prelude

import Data.Foldable (traverse_)
import Data.Newtype (wrap)
import Data.Set as Set
import Effect (Effect)
import Effect.Ref as Ref
import FRP.Event (Event, makeEvent, subscribe)
import Web.Event.EventTarget (addEventListener, eventListener, removeEventListener)
import Web.HTML (window)
import Web.HTML.Window (toEventTarget)
import Web.UIEvent.KeyboardEvent (code, fromEvent)

-- | A handle for creating events from the keyboard.
newtype Keyboard = Keyboard
  { keys :: Ref.Ref (Set.Set String)
  , dispose :: Effect Unit
  }
  
-- | Get a handle for working with the keyboard.
getKeyboard :: Effect Keyboard
getKeyboard = do
  keys <- Ref.new Set.empty
  target <- toEventTarget <$> window
  keyDownListener <- eventListener \e -> do
    fromEvent e # traverse_ \ke ->
      Ref.modify (Set.insert (code ke)) keys
  keyUpListener <- eventListener \e -> do
    fromEvent e # traverse_ \ke ->
      Ref.modify (Set.delete (code ke)) keys
  addEventListener (wrap "keydown") keyDownListener false target
  addEventListener (wrap "keyup") keyUpListener false target
  let dispose = do
        removeEventListener (wrap "keydown") keyDownListener false target
        removeEventListener (wrap "keyup") keyUpListener false target
  pure (Keyboard { keys, dispose })

disposeKeyboard :: Keyboard -> Effect Unit
disposeKeyboard (Keyboard { dispose }) = dispose

-- | Create an `Event` which fires when a key is pressed
down :: Event String
down = makeEvent \k -> do
  target <- toEventTarget <$> window
  keyDownListener <- eventListener \e -> do
    fromEvent e # traverse_ \ke ->
      k (code ke)
  addEventListener (wrap "keydown") keyDownListener false target
  pure (removeEventListener (wrap "keydown") keyDownListener false target)

-- | Create an `Event` which fires when a key is released
up :: Event String
up = makeEvent \k -> do
  target <- toEventTarget <$> window
  keyUpListener <- eventListener \e -> do
    fromEvent e # traverse_ \ke ->
      k (code ke)
  addEventListener (wrap "keyup") keyUpListener false target
  pure (removeEventListener (wrap "keyup") keyUpListener false target)

-- | Create an event which also returns the currently pressed keys.
withKeys
  :: forall a
   . Keyboard
  -> Event a
  -> Event { value :: a, keys :: Set.Set String }
withKeys (Keyboard { keys }) e = makeEvent \k ->
  e `subscribe` \value -> do
    keysValue <- Ref.read keys
    k { value, keys: keysValue }
