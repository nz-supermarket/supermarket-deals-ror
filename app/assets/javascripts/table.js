var table = angular.module('table', ['ngTable']);

var tableCtrl = function($scope, $filter, ngTableParams) {
  var data = gon.products;

  $scope.tableParams = new ngTableParams({
        page: 1,            // show first page
        count: 50,          // count per page
        filter: {
            name: ''       // initial filter
        }, 
        sorting: {
            name: 'asc'     // initial sorting
        }
    }, {
        total: data.length, // length of data
        getData: function($defer, params) {
            // use build-in angular filter
            var filteredData = params.filter() ? $filter('filter')(data, params.filter()) : data; 
            var orderedData = params.sorting() ? $filter('orderBy')(filteredData, params.orderBy()) : data;
            params.total(orderedData.length); // set total for recalc pagination 
            $defer.resolve(orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count()));
        }
    }); 

  function init() {

  }

  init();
}

table.controller('tableCtrl', tableCtrl)
