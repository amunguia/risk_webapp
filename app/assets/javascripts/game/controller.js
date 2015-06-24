var app = angular.module('riskGame');

app.controller('gameController', ['$scope', '$window', 'gameService',
    function($scope, $window, gameService) {
        $scope.game                = {};
        $scope.messages            = [];
        $scope.currentCountry      = null;
        $scope.attackCountry       = null;
        $scope.defendCountry       = null;
        $scope.game.moveArmies     = 0;
        $scope.game.moveOptions    = [];
        $scope.game.placeArmies    = 0;
        $scope.game.placeOptions   = [];

        gameService.initialize($scope);

        $scope.attack = function() {
            if ($scope.defendCountry == null || !isPlayersTurn()) {
                return;
            }

            var attack_with = 1;
            if ($scope.game.army_map[$scope.attackCountry] == 3) {
                attack_with = 2;
            } else if ($scope.game.army_map[$scope.attackCountry] > 3) {
                attack_with = 3;
            }

            gameService.attack($scope.attackCountry, $scope.defendCountry, attack_with);
            $scope.attackCountry = null;
            $scope.defendCountry = null;
        }

        $scope.move = function() {
            if ($scope.defendCountry == null || !isPlayersTurn() || $scope.game.moveArmies <= 0) {
                return;
            }

            gameService.move($scope.attackCountry, $scope.defendCountry, $scope.game.moveArmies);
            $scope.attackCountry = null;
            $scope.defendCountry = null;
            $scope.game.moveArmies    = 0;
        }

        $scope.noMove = function() {
            if (!isPlayersTurn()) {
                return;
            }
            gameService.noMove();
        }

        $scope.place = function() {
            if (!isPlayersTurn() || $scope.game.placeArmies < 1) {
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
            console.log($scope.attackCountry + "\t"+$scope.defendountry);
            if (isPlayersTurn()) {
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

        function isPlayersTurn() {
            return true;
        }
        
        function requiresSecondCountry() {
            return $scope.game.state == 1 ||
                   $scope.game.state == 3;
        }

}]);