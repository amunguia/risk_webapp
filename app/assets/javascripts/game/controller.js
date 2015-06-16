var app = angular.module('riskGame');

app.controller('gameController', ['$scope', '$http', '$window', 
    function($scope, $http, $window) {
        $scope.game    = {};

        //Initialize game state.
        $http.get(""+$window._GAMEID+"/state").success(function(data){
            $scope.game = data;
        });
        
        //Register on game channnel
        var dispatcher = new WebSocketRails('localhost:3000/websocket');
        var channel    = dispatcher.subscribe('game');
        channel.bind('state', function(game) {
            $scope.$apply(function() {
                $scope.game = game;
            });
        });

        $scope.touchCountry = function(country) {
            console.log(country);
            console.log(state());
        }

        function state() {
            if ($scope.game.state) {
                return $scope.game.state;
            } else {
                return 0;
            }
        }
}]);