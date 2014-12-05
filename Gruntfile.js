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

    uglify: {
      lib: {
        files: {
          "dist/behavior.min.js": ["js/behavior.js"]
        }
      }
    },

    dotPsci: ["<%=libFiles%>"]
  });

  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-uglify");
  grunt.loadNpmTasks("grunt-purescript");

  grunt.registerTask("make", ["pscMake:lib", "pscDocs:lib", "dotPsci"]);
  grunt.registerTask("example", ["psc:example"]);
  grunt.registerTask("minify", ["uglify:lib"]);
  grunt.registerTask("default", ["clean", "make", "example"]);
};
