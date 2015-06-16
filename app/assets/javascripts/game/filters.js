var app = angular.module('riskGame');

app.filter('gameObjFilter', function(){
    return function(input, objName, key) {
        var obj = input[objName];
        var val = undefined;
        if (obj && obj[key] !== undefined && obj[key] >= 0) {
            return obj[key];
        } else {
            return "-";
        }
    };
});

app.filter('gameOwnerFilter', function(){
    return function(input, countryName) {
        switch(countryName) {
            case 1:
                return "player1_owns";
            case 2:
                return "player2_owns";
            case 3:
                return "player3_owns";
            case 4:
                return "player4_owns";
            case 5: 
                return "player5_owns";
            case 6:
                return "player6_owns";
            case 7:
                return "player7_owns";
            case 8:
                return "player8_owns";
            default:
                return "unowned";
        }
    };
});