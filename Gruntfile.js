module.exports = function(grunt) {

  "use strict";

  grunt.initConfig({

    libFiles: [
      "src/**/*.purs",
      "bower_components/purescript-*/src/**/*.purs"
    ],

    clean: ["tmp", "output"],

    pscMake: {
      lib: {
        src: ["<%=libFiles%>"]
      }
    },

    psc: {
      options: {
        main: "Main",
        modules: ["Main"]
      },
      example: {
        src: ["<%=libFiles%>", "example/Main.purs"],
        dest: "js/example.js"
      }
    },

    pscDocs: {
      lib: {
        src: ["src/**/*.purs"],
        dest: "docs/README.md"
      }
    },

    dotPsci: ["<%=libFiles%>"]
  });

  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-purescript");

  grunt.registerTask("make", ["pscMake:lib", "pscDocs:lib", "dotPsci"]);
  grunt.registerTask("example", ["psc:example"]);
  grunt.registerTask("default", ["clean", "make", "example"]);
};
