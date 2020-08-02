module.exports = {
    ifeq: function (a, b, options) {
        //console.log("a"+a)
        //console.log("b"+b)
        if (a === b) {
            return options.fn(this);
        }
        return options.inverse(this);
    },
    userRole: function (a) {
        if (a == 'ADMIN') {
            return 'Admin';
        } else if (a == 'NORMAL') {
            return 'Normal';
        } else if (a == 'ORGANIZATOR') {
            return 'Organizatör';
        } else if (a == 'PLACE_OWNER') {
            return 'Mekan Sahibi';
        } else if (a == 'ACTOR') {
            return 'Sanatçı';
        }
    }, isEmpty: function (a, options) {
        if (a.length === 0) {
            return options.fn(this);
        }
        return options.inverse(this);
    }, isNotEmpty: function (a, options) {
        console.log(a);
        if (a.length > 0) {
            return options.fn(this);
        }
        return options.inverse(this);
    },
    bar: function () {
        return "BAR!";
    }
};