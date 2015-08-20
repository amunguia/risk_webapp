var app = angular.module('riskGame');

app.factory('gameService', ['$http', '$window', function($http, $window) {
    var dispatcher = new WebSocketRails('shrouded-sands-8100.herokuapp.com/websocket');
    var channel    = dispatcher.subscribe("game"+$window._GAMEID);
    var scope      = undefined;

    function getScope() {
        return scope;
    }

    function setScope(s) {
        scope = s;
    }

    function receive(data) {
        console.log(data);
    }

    function updateMoveOptions() {
        var armies = scope.game.army_map[scope.attackCountry] - 1;
        var start  = scope.game.minimum_move;
        moveOptions = [];
        for (var i = scope.game.minimum_move; i <= armies; i++) {
            moveOptions.unshift(i);
        }
        scope.game.moveOptions = moveOptions;
    }

    function updateState(game)  {
        console.log(game);
        scope.game              = game;
        scope.game.placeArmies  = game.max_place;
        options = []
        for (var i = 1; i <= scope.game.placeArmies; i++) {
            options.unshift(i);
        }
        scope.game.placeOptions = options;

        if (game.state == 3) {
            scope.attackCountry = game.move_from
            scope.defendCountry = game.move_to
            updateMoveOptions();
        }
    }

    return {

        initialize: function(scope) {
            setScope(scope);

            //Initialize game state.
            $http.get(""+$window._GAMEID+"/state").success(updateState);
            $http.get(""+$window._GAMEID+"/players").success(function(data) {
                for (var i = 0; i < data.length; i++) {
                    scope.currentPlayers.push(data[i]);
                }
            });
            
            //Bind to relevant channels
            channel.bind('state', function(game) {
                scope.$apply(function() {
                    updateState(game);
                });
            });

            channel.bind('message', function(message) {
                scope.$apply(function() {
                    scope.messages.unshift(message);
                });
            });

            channel.bind('users', function(player) {
                scope.$apply(function() {
                    if (player.name) {
                        scope.currentPlayers.push(player);
                    }
                    if (player.name == scope.game.username) {
                        scope.game.joined = true;
                    }
                });
            });
        },

        attack: function(attackCountry, defendCountry, number) {
            var data = {
                game: $window._GAMEID,
                attack_country: attackCountry,
                defend_country: defendCountry,
                attack_with: number,
            };
            console.log(data);
            dispatcher.trigger('game.attack', data, receive, receive);
        },

        joinGame: function(name) {
            var data = {
                game: $window._GAMEID,
                username: name
            };
            dispatcher.trigger('game.join', data, receive, receive);
        },

        isPlayersTurn: function() {
            return $window._USERID == scope.game.current_player;
        },

        move: function(fromCountry, toCountry, number) {
            var data = {
                game: $window._GAMEID,
                source_country: fromCountry,
                destination_country: toCountry,
                number_armies: number
            };
            console.log(data);
            dispatcher.trigger('game.move', data, receive, receive);
        },

        noMove: function() {
            dispatcher.trigger('game.no_move', {game: $window._GAMEID}, receive, receive);
        },

        place: function(intoCountry, number) {
            var data = {
                game: $window._GAMEID,
                armies: number,
                country: intoCountry
            };
            console.log(data);
            dispatcher.trigger('game.place', data, receive, receive);
        },

        updateMoveOptions: function() {
            updateMoveOptions();
        }
    };
}]);