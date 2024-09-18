"use strict";
exports.__esModule = true;
exports.HotkeylessAHKServer = void 0;
var express = require("express");
var util = require('util')
var HotkeylessAHKServer = /** @class */ (function () {
    function HotkeylessAHKServer(serverPort) {
        var _this = this;
        this.serverPort = serverPort;
        // Setup server
        this.app = express();
        this.router = express.Router();
        this.pendingResult = null;
        this.list = "";
        this.params = ""
        /**
         * Handles the subscriber aka. redirecting ahk script
         */
        this.subscribe = function (req, res) {
            _this.pendingResult = res;
            // console.log("Received subscriber");
        };
        /**
         * Handles the sender aka the caller e.g. a stream deck
         */
        this.send = function (req, res) {
            if (_this.pendingResult !== null) {
                // var cmd = req.params.cmd;
                // var cmdParams = req.params.cmd;
                _this.pendingResult.send(req.params);
                // _this.pendingResult.send({"cmd":cmd, "cmdParams":cmdParams});
                // console.log({"cmd":cmd, "cmdParams":cmdParams})

                _this.pendingResult = null;
                res.send("success");
                // console.log("Send ".concat({"cmd":cmd, "cmdParams":cmdParams}));
            
                // console.log("SEND res.params.cmds => " + JSON.stringify(req.params.cmds));
                // console.log("SEND res.params.params => " + JSON.stringify(req.params.params));
                // console.log("SEND req.query => " + JSON.stringify(req.query));
            }
            else {
                console.error("No subscribing process registered. Please call '/subscribe' first!");
                res.send("failure");
            }
        };
        this.register = function (req, res) {

            var cmds = req.params.cmds;
            var params = req.params.params;
            // This is required due to the last comma added in the ahk code
            // _this.list = list.substring(0, list.length - 1);
            res.send("success");
            // console.log("Register methods => " + list);
            // console.log("Register paarams => " + params);
            
            console.log("REGISTER req.params.cmds => " + JSON.stringify(req.params.cmds));
            console.log("REGISTER req.params.params => " + JSON.stringify(req.params.params));
        };
        this.getList = function (req, res) {
            res.send(_this.list);
        };
        this.getParams = function (req, res) {
            res.send(_this.params);
        };
        /**
         * Stops the node process
         */
        this.kill = function (req, res) {
            console.log("Shutting down server...");
            process.exit(0);
        };
    }
    HotkeylessAHKServer.prototype.setup = function () {
        console.log("Starting server => ");
        this.router.get("/subscribe", this.subscribe);
        this.router.get("/send/:cmd", this.send);
        this.router.get("/kill", this.kill);
        this.router.get("/register/commands/:cmds/parameters/:params", this.register);
        this.router.get("/list", this.getList);
        this.router.get("/params", this.getParams)
        // Start server
        this.app.use('/', this.router);
        this.app.listen(this.serverPort);
        // console.log("Server running on port ".concat(this.serverPort, "."));
        // console.log("Please use the '/subscribe' endpoint first!");
    };
    return HotkeylessAHKServer;
}());
exports.HotkeylessAHKServer = HotkeylessAHKServer;
