module.exports = function(app) {
    app.get('/testroute', function (req, res) {
        res.send('Hello World!');
    });
};
