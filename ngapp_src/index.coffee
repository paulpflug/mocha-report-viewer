angular = require("angular")
require("angular-animate")
require("angular-aria")
ngmaterial = require("angular-material")
io = require("socket.io-client")
require("./index.css")

reporterApp = angular.module "reporterApp", [ngmaterial]

reporterApp.controller "appCtrl", ($scope,$mdToast) ->
  socket = io()
  $scope.data = []
  $scope.failed = []
  levels = []
  $scope.count = 0
  $scope.tests = 0
  socket.emit "livereload"
  socket.once "livereload", (response) ->
    console.log "starting livereload"
    if response
      scripttag = document.createElement("script")
      scripttag.setAttribute("type","text/javascript")
      scripttag.setAttribute("src",window.location.protocol + "//" + window.location.hostname+":"+response)
      document.getElementsByTagName("body")[0].appendChild(scripttag)
  $scope.splitNewLine = (string) ->
    return string.split("\n")
  parse = (data) ->
    if data[0]
      if data[0] == "start"
          $scope.data = []
          $scope.failed = []
          count = data[0][1].total
      else if data[0] == "fail"
        $scope.failed.push(data[1])
      else if data[0] == "pass"
        $scope.data.push(data[1])
      else if data[0] == "end"
        $scope.count = $scope.data.length
        $scope.tests = data[1].tests
        $mdToast.show($mdToast.simple().content('Test finished'))
      if data[0] == "fail" or data[0] == "pass"
        identifier = data[1].fullTitle.replace(data[1].title,"").replace(/\s+$/,"")
        difference = identifier
        newlevels = []
        for lvl in levels
          if identifier.indexOf(lvl) > -1
            difference = difference.replace(lvl,"").replace(/^s+/,"")
            newlevels.push lvl
        if difference
          newlevels.push difference
        data[1].levels = newlevels
        levels = newlevels.slice()

  reload = () ->
    $scope.data = []
    socket.emit "data"
    socket.on "data", (response) ->
      if response
        for data in response
          parse(data)
        $scope.$$phase || $scope.$digest()
  reload()
  socket.on "data", (data) ->
    parse(data)
    $scope.$$phase || $scope.$digest()

