var app = angular.module('riskGame');

app.controller('gameController', ['$scope', '$window', 'gameService',
    function($scope, $window, gameService) {
        $scope.game                = {};
        $scope.messages            = [];
        $scope.currentPlayers      = [];
        $scope.currentCountry      = null;
        $scope.attackCountry       = null;
        $scope.defendCountry       = null;
        $scope.game.moveArmies     = 0;
        $scope.game.moveOptions    = [];
        $scope.game.placeArmies    = 0;
        $scope.game.placeOptions   = [];
        $scope.game.joined         = false;
        $scope.game.username       = "";

        gameService.initialize($scope);

        $scope.attack = function() {
            if ($scope.defendCountry == null || !gameService.isPlayersTurn()) {
                return;
            }

            var attack_with = 1;
            if ($scope.game.army_map[$scope.attackCountry] == 3) {
                attack_with = 2;
            } else if ($scope.game.army_map[$scope.attackCountry] > 3) {
                attack_with = 3;
            }

            gameService.attack($scope.attackCountry, $scope.defendCountry, attack_with);
        }

        $scope.join = function() {
            if ($scope.game.username.length < 1) {
                $scope.game.error = "Please choose a username.";
                return;
            }
            gameService.joinGame($scope.game.username);

        }

        $scope.move = function() {
            if ($scope.defendCountry == null || !gameService.isPlayersTurn() || 
                !$scope.game.moveArmies ||  $scope.game.moveArmies <= 0) {
                return;
            }

            gameService.move($scope.attackCountry, $scope.defendCountry, $scope.game.moveArmies);
            $scope.attackCountry      = null;
            $scope.defendCountry      = null;
            $scope.game.moveArmies    = 0;
        }

        $scope.noMove = function() {
            if (!gameService.isPlayersTurn()) {
                return;
            }
            gameService.noMove();
        }

        $scope.place = function() {
            if (!gameService.isPlayersTurn() || $scope.game.placeArmies < 1) {
                return;
            }
            
            gameService.place($scope.attackCountry, $scope.game.placeArmies);
            $scope.attackCountry = null;
            $scope.game.placeArmies   = 0;
        }

        $scope.countryClass = function(country, defaultClass) {
            if ($scope.attackCountry === country) {
                return "attack-country";
            } else if ($scope.defendCountry === country) {
                return "defend-country";
            } else {
                return defaultClass;
            }
        }

        $scope.clickCountry = function(country) {
            if (gameService.isPlayersTurn()) {
                switch($scope.game.state) {
                    case 1:
                        clickWhileAttack(country);
                        break;
                    case 2:
                    case 5:
                        clickWhilePlace(country);
                        break;
                }
            }

            if ($scope.defendCountry != null) {
                gameService.updateMoveOptions();
            }
        }

        function clickWhileAttack(country) {
           if ($scope.attackCountry && requiresSecondCountry()) {
                if ($scope.attackCountry === country) {
                    $scope.attackCountry = null;     //Unset attackCountry
                    $scope.defendCountry = null;
                } else if ($scope.defendCountry == country) {
                    $scope.defendCountry = null;     //Unset defendCountry
                } else {
                    $scope.defendCountry = country;  //Set defendCountry
                }
            } else {
                $scope.attackCountry = country;      //Set attackCountry
            }
        }

        function clickWhilePlace(country) {
            $scope.attackCountry = country;
        }

        $scope.isPlayersTurn = function () {
            return gameService.isPlayersTurn();
        }
        
        function requiresSecondCountry() {
            return $scope.game.state == 1 ||
                   $scope.game.state == 3;
        }

}]);