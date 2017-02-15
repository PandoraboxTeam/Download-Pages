(function() {
  'use strict';
  angular.module('PB', [], angular.noop).controller('BaseController', function($scope, $http, $q) {
    var DOWNLOAD_SITEPATH, dataRaw;
    DOWNLOAD_SITEPATH = "http://downloads.pandorabox.com.cn";
    dataRaw = [];
    $scope.list = [];
    $scope.curPath = '/';
    $scope.curQueue = [];
    $scope.$watchCollection('curQueue', function() {
      var i, index, item, len, ref, rel;
      $scope.curPath = '/' + $scope.curQueue.join('/');
      if ($scope.curPath.length !== 1) {
        $scope.curPath += '/';
      }
      ref = $scope.list;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        item = ref[index];
        if (!(item.list == null)) {
          continue;
        }
        $scope.list[index].href = "" + DOWNLOAD_SITEPATH + $scope.curPath + item.name;
        if ((item.date == null) && ((rel = item.name.match(/20(\d{2}-\d{2}-\d{2}|\d{6})/)) != null)) {
          if (!/-/.test(rel[0])) {
            rel[0] = rel[0].slice(0, 4) + "-" + rel[0].slice(4, 6) + "-" + rel[0].slice(6, 8);
          }
          $scope.list[index].date = rel[0];
        }
      }
    });
    $scope.enter = function(item) {
      var curQueue;
      curQueue = angular.copy($scope.curQueue);
      curQueue.push(item.name);
      (item.list !== 'online' ? $q.resolve(item) : $http.get("/data-" + (curQueue.join('-')) + ".json").success(function(data) {
        return item.list = data;
      })).then(function() {
        $scope.list = item.list;
        return $scope.curQueue.push(item.name);
      });
    };
    $scope.prev = function() {
      var curQueue, i, item, j, key, len, len1, list, val;
      if ($scope.curQueue.length === 0) {
        return;
      }
      curQueue = angular.copy($scope.curQueue);
      curQueue.pop();
      list = dataRaw;
      for (i = 0, len = curQueue.length; i < len; i++) {
        key = curQueue[i];
        for (j = 0, len1 = list.length; j < len1; j++) {
          val = list[j];
          if (!(val.name === key)) {
            continue;
          }
          item = val;
          break;
        }
        list = item.list;
        continue;
      }
      $scope.list = list;
      $scope.curQueue = curQueue;
    };
    $http.get('/data.json').success(function(data) {
      dataRaw = data;
      $scope.list = dataRaw != null ? dataRaw : [];
    });
  });

}).call(this);
