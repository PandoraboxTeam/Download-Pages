'use strict'

angular.module('PB', [], angular.noop)

.controller('BaseController', ($scope, $http, $q) ->
    DOWNLOAD_SITEPATH = "http://downloads.pandorabox.com.cn"
    dataRaw = [ ]
    $scope.list = [ ]

    $scope.curPath = '/'
    $scope.curQueue = [ ]
    $scope.$watchCollection 'curQueue', ->
        $scope.curPath = '/' + $scope.curQueue.join('/')
        if $scope.curPath.length isnt 1
            $scope.curPath += '/'
        for item, index in $scope.list when not item.list?
            $scope.list[index].href = """
                #{DOWNLOAD_SITEPATH}#{$scope.curPath}#{item.name}
            """
            if (not item.date?) and
                    (rel = item.name.match(///
                        20(\d{2}-\d{2}-\d{2}
                        |
                        \d{6})
                    ///))?
                if not /-/.test rel[0]
                    rel[0] = "#{rel[0][..3]}-#{rel[0][4..5]}-#{rel[0][6..7]}"
                $scope.list[index].date = rel[0]
        return

    $scope.enter = (item) ->
        curQueue = angular.copy $scope.curQueue
        curQueue.push item.name
        (if item.list isnt 'online'
            $q.resolve(item)
        else
            $http.get("/data-#{curQueue.join('-')}.json").success (data) ->
                item.list = data
        ).then ->
            $scope.list = item.list
            $scope.curQueue.push item.name
        return

    $scope.prev = ->
        return if $scope.curQueue.length is 0
        curQueue = angular.copy $scope.curQueue
        curQueue.pop()
        list = dataRaw
        for key in curQueue
            for val in list when val.name is key
                item = val
                break
            list = item.list
            continue
        $scope.list     = list
        $scope.curQueue = curQueue
        return

    $http.get('/data.json').success (data) ->
        dataRaw = data
        $scope.list = dataRaw ? [ ]
        return

    return
)
