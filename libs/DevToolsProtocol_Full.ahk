
#Include InterfaceA.ahk
#Include utils.ahk
#Include Timer.ahk


class DevToolsProtocol extends Interface {
    domains := Map()

    __New(webView, console) {
        this.console := console

        ; this.setupInterface()

        for key, value in DevToolsProtocol.OwnProps() {
            if (value.HasProp("prototype") && value.prototype.__Class != DevToolsProtocol.Base.prototype.__Class) {
                this.domains[key] := value(webView, console)

                if(this.domains[key].endpoints.Count > 0 ) {
                    myEndpoint := this.domains[key].endpoints
                    this.register(myEndpoint) 
                }
            }
        }
    }

    class Base extends Interface {
        wv2 := ""
        console := ""
        targetDomainName := ""
        isenabled := false
        lastenableAttempt := 0
        throttlePeriod := 1000  ; Milliseconds
        recieveTimeerPeriod := 250
        idleTimer := 0

        __Call(name, params) {
            super.__Call(name, params)
        }   

        __New(wv2, console) {  
            this.wv2 := wv2
            this.console := console
            this.targetDomainName := this.base.base.__Class != "DevToolsProtocol.Base" ? this.base.base.__Class : this.base.__Class
            this.targetDomainName := StrSplit(this.targetDomainName, ".").Has(2) ? StrSplit(this.targetDomainName, ".")[2] : this.targetDomainName ;

            super.__New()
        }


        send(method, params, callback := "") {
            try {
                params := Utils.ObjectRemoveEmptyProps(params)
                jsonString := Utils.ToString(params)
                ; jsonString := Utils.ObjectToJson(params)
                methodString := this.targetDomainName "." method
                this.wv2.CallDevToolsProtocolMethod(methodString, jsonString, WebView2.Handler(handleResponse))
                handleResponse(sender, wv2, args) {
                    try {
                        _args := StrGet(args)
                        _args := Utils.MapToObject(Jxon_Load(&_args))
                        if (callback) {
                            callback.call(_args)
                        }
                    }
                    catch Error as e {
                        this.console.log("Error handling response at line " e.Line ": " e.Message)
                    }
                }
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        receive(event, callback) {

            receiver := this.wv2.GetDevToolsProtocolEventreceiver(this.targetDomainName "." event)
            receiver.add_DevToolsProtocolEventreceived(WebView2.Handler(handleEvent))
            handleEvent(sender, wv2, args) {
                try {
                    _args := WebView2.DevToolsProtocolEventreceivedEventArgs(args)
                    _args := _args.ParameterObjectAsJson
                    if (callback) {
                        callback.call(Utils.JsonToObject(_args))
                    }
                }
                catch Error as e {
                    this.console.log("Error handling event at line " e.Line ": " e.Message)
                }
            }
        }

        enable(callback := "") {
            try {
                currentTime := A_TickCount
                if (!this.isenabled && currentTime - this.lastenableAttempt > this.throttlePeriod) {
                    this.send("enable", {}, callback)
                    this.isenabled := true
                    this.lastenableAttempt := currentTime
                }
                else {
                    callback.call({})
                }
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        disable(callback := "") {
            try {
                if (this.isenabled) {
                    this.send("disable", {}, callback)
                    this.isenabled := false
                }
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        handleError(e) {
            if (this.console) {
                this.console.log("Error handling event at line " e.Line ": " e.Message)
            } else {
                MsgBox("Error handling event at line " e.Line ": " e.Message)
            }
        }
    }


    class Accessibility extends DevToolsProtocol.Base {

        getAXNodeAndAncestors(nodeId, backendNodeId, objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        backendNodeId: backendNodeId,
                        objectId: objectId
                    }
                    this.send("getAXNodeAndAncestors", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getChildAXNodes(id, frameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        id: id,
                        frameId: frameId
                    }
                    this.send("getChildAXNodes", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getFullAXTree(depth, frameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        depth: depth,
                        frameId: frameId
                    }
                    this.send("getFullAXTree", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getPartialAXTree(nodeId, backendNodeId, objectId, fetchRelatives, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        backendNodeId: backendNodeId,
                        objectId: objectId,
                        fetchRelatives: fetchRelatives
                    }
                    this.send("getPartialAXTree", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getRootAXNode(frameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId
                    }
                    this.send("getRootAXNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        queryAXTree(nodeId, backendNodeId, objectId, accessibleName, role, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        backendNodeId: backendNodeId,
                        objectId: objectId,
                        accessibleName: accessibleName,
                        role: role
                    }
                    this.send("queryAXTree", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadComplete(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("loadComplete", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        nodesUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("nodesUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

    }

    class Animation extends DevToolsProtocol.Base {

        getCurrentTime(animationId, callback := "") {
            try {
                params := {
                    animationId: animationId
                }
                onEnabled(args) {
                    this.send("getCurrentTime", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        getPlaybackRate(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getPlaybackRate", {}, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        releaseAnimations(animations, callback := "") {
            try {
                params := {
                    animations: animations
                }
                onEnabled(args) {
                    this.send("releaseAnimations", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        resolveAnimation(animationId, callback := "") {
            try {
                params := {
                    animationId: animationId
                }
                onEnabled(args) {
                    this.send("resolveAnimation", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        seekAnimations(animations, currentTime, callback := "") {
            try {
                params := {
                    animations: animations,
                    currentTime: currentTime
                }
                onEnabled(args) {
                    this.send("seekAnimations", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        setpaused(animations, paused, callback := "") {
            try {
                params := {
                    animations: animations,
                    paused: paused
                }
                onEnabled(args) {
                    this.send("setpaused", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        setPlaybackRate(playbackRate, callback := "") {
            try {
                params := {
                    playbackRate: playbackRate
                }
                onEnabled(args) {
                    this.send("setPlaybackRate", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        setTiming(animationId, duration, delay, callback := "") {
            try {
                params := {
                    animationId: animationId,
                    duration: duration,
                    delay: delay
                }
                onEnabled(args) {
                    this.send("setTiming", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        animationCanceled(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("animationCanceled", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        animationCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("animationCreated", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        animationstarted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("animationstarted", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        animationUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("animationUpdated", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }
    }

    class Audits extends DevToolsProtocol.Base {

        checkcontrast(reportAAA := false, callback := "") {
            try {
                params := {
                    reportAAA: reportAAA
                }
                onEnabled(args) {
                    this.send("checkcontrast", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        checkFormsIssues(callback := "") {
            try {
                onEnabled(args) {
                    this.send("checkFormsIssues", {}, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        getEncodedResponse(requestId, encoding, quality := 1, sizeOnly := false, callback := "") {
            try {
                params := {
                    requestId: requestId,
                    encoding: encoding,
                    quality: quality,
                    sizeOnly: sizeOnly
                }
                this.send("getEncodedResponse", params, callback)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        issueAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("issueAdded", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }
    }

    class Autofill extends DevToolsProtocol.Base {

        setAddresses(addresses, callback := "") {
            try {
                params := {
                    addresses: addresses
                }
                onEnabled(args) {
                    this.send("setAddresses", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        trigger(fieldId, frameId, card, callback := "") {
            try {
                params := {
                    fieldId: fieldId,
                    frameId: frameId,
                    card: card
                }
                onEnabled(args) {
                    this.send("trigger", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        addressFormFilled(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("addressFormFilled", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }
    }

    class BackgroundService extends DevToolsProtocol.Base {

        clearEvents(service, callback := "") {
            try {
                params := {
                    service: service
                }
                onEnabled(args) {
                    this.send("clearEvents", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        setRecording(shouldRecord, service, callback := "") {
            try {
                params := {
                    shouldRecord: shouldRecord,
                    service: service
                }
                onEnabled(args) {
                    this.send("setRecording", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        startObserving(service, callback := "") {
            try {
                params := {
                    service: service
                }
                onEnabled(args) {
                    this.send("startObserving", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        stopObserving(service, callback := "") {
            try {
                params := {
                    service: service
                }
                onEnabled(args) {
                    this.send("stopObserving", params, callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        backgroundServiceEventReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("backgroundServiceEventReceived", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }

        recordingStateChanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("recordingStateChanged", callback)
                }
                this.enable(onEnabled)
            }
            catch Error as e {
                this.handleError(e)
            }
        }
    }

    class Browser extends DevToolsProtocol.Base {

        addPrivacySandboxEnrollmentOverride(url, callback := "") {
            try {
                onEnabled(args) {
                    params := { url: url }
                    this.send("addPrivacySandboxEnrollmentOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        close(callback := "") {
            try {
                onEnabled(args) {
                    params := {}
                    this.send("close", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getVersion(callback := "") {
            try {
                onEnabled(args) {
                    params := {}
                    this.send("getVersion", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resetPermissions(browserContextId, callback := "") {
            try {
                onEnabled(args) {
                    params := { browserContextId: browserContextId }
                    this.send("resetPermissions", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        cancelDownload(guid, browserContextId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        guid: guid,
                        browserContextId: browserContextId
                    }
                    this.send("cancelDownload", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        crash(callback := "") {
            try {
                onEnabled(args) {
                    params := {}
                    this.send("crash", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        crashGpuProcess(callback := "") {
            try {
                onEnabled(args) {
                    params := {}
                    this.send("crashGpuProcess", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        executeBrowserCommand(commandId, callback := "") {
            try {
                onEnabled(args) {
                    params := { commandId: commandId }
                    this.send("executeBrowserCommand", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getBrowserCommandLine(callback := "") {
            try {
                onEnabled(args) {
                    params := {}
                    this.send("getBrowserCommandLine", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getHistogram(name, delta, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        name: name,
                        delta: delta
                    }
                    this.send("getHistogram", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getHistograms(query, delta, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        query: query,
                        delta: delta
                    }
                    this.send("getHistograms", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getWindowBounds(windowId, callback := "") {
            try {
                onEnabled(args) {
                    params := { windowId: windowId }
                    this.send("getWindowBounds", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getWindowForTarget(targetId, callback := "") {
            try {
                onEnabled(args) {
                    params := { targetId: targetId }
                    this.send("getWindowForTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        grantPermissions(permissions, origin, browserContextId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        permissions: permissions,
                        origin: origin,
                        browserContextId: browserContextId
                    }
                    this.send("grantPermissions", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDockTile(badgeLabel, image, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        badgeLabel: badgeLabel,
                        image: image
                    }
                    this.send("setDockTile", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDownloadBehavior(behavior, browserContextId, downloadPath, eventsenabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        behavior: behavior,
                        browserContextId: browserContextId,
                        downloadPath: downloadPath,
                        eventsenabled: eventsenabled
                    }
                    this.send("setDownloadBehavior", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setPermission(permission, setting, origin, browserContextId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        permission: permission,
                        setting: setting,
                        origin: origin,
                        browserContextId: browserContextId
                    }
                    this.send("setPermission", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setWindowBounds(windowId, bounds, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        windowId: windowId,
                        bounds: bounds
                    }
                    this.send("setWindowBounds", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        downloadProgress(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("downloadProgress", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        downloadWillBegin(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("downloadWillBegin", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class CacheStorage extends DevToolsProtocol.Base {

        deleteCache(cacheId, callback := "") {
            try {
                onEnabled(args) {
                    params := { cacheId: cacheId }
                    this.send("deleteCache", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        deleteEntry(cacheId, request, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cacheId: cacheId,
                        request: request
                    }
                    this.send("deleteEntry", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestCachedresponse(cacheId, requestURL, requestHeaders, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cacheId: cacheId,
                        requestURL: requestURL,
                        requestHeaders: requestHeaders
                    }
                    this.send("requestCachedresponse", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestCacheNames(securityOrigin, storageKey, storageBucket, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        securityOrigin: securityOrigin,
                        storageKey: storageKey,
                        storageBucket: storageBucket
                    }
                    this.send("requestCacheNames", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestEntries(cacheId, skipCount, pageSize, pathFilter, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cacheId: cacheId,
                        skipCount: skipCount,
                        pageSize: pageSize,
                        pathFilter: pathFilter
                    }
                    this.send("requestEntries", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Cast extends DevToolsProtocol.Base {

        setsinkToUse(sinkName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        sinkName: sinkName
                    }
                    this.send("setsinkToUse", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startDesktopMirroring(sinkName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        sinkName: sinkName
                    }
                    this.send("startDesktopMirroring", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startTabMirroring(sinkName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        sinkName: sinkName
                    }
                    this.send("startTabMirroring", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopCasting(sinkName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        sinkName: sinkName
                    }
                    this.send("stopCasting", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        issueUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("issueUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        sinksUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("sinksUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Console extends DevToolsProtocol.Base {

        clearMessages(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearMessages", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        messageAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("messageAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    ;;CSS skipped for now

    class Database extends DevToolsProtocol.Base {


        executeSQL(databaseId, query, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        databaseId: databaseId,
                        query: query
                    }
                    this.send("executeSQL", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getDatabaseTableNames(databaseId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        databaseId: databaseId
                    }
                    this.send("getDatabaseTableNames", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        addDatabase(database := "", callback := "") {
            try {
                onEnabled(args) {
                    this.receive("addDatabase", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Debugger extends DevToolsProtocol.Base {


        continueToLocation(location, targetCallFrames := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        location: location,
                        targetCallFrames: targetCallFrames
                    }
                    this.send("continueToLocation", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        evaluateOnCallFrame(callFrameId, expression, objectGroup := "", includeCommandLineAPI := "", silent := "", returnByValue := "", generatePreview := "", throwOnSideEffect := "", timeout := "", disableBreaks := "", replMode := "", allowUnsafeEvalBlockedByCSP := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        callFrameId: callFrameId,
                        expression: expression,
                        objectGroup: objectGroup,
                        includeCommandLineAPI: includeCommandLineAPI,
                        silent: silent,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        throwOnSideEffect: throwOnSideEffect,
                        timeout: timeout,
                        disableBreaks: disableBreaks,
                        replMode: replMode,
                        allowUnsafeEvalBlockedByCSP: allowUnsafeEvalBlockedByCSP
                    }
                    this.send("evaluateOnCallFrame", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getPossibleBreakpoints(start := "", end := "", restrictToFunction := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        start: start,
                        end: end,
                        restrictToFunction: restrictToFunction
                    }
                    this.send("getPossibleBreakpoints", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getScriptSource(scriptId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptId: scriptId
                    }
                    this.send("getScriptSource", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getStackTrace(stackTraceId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        stackTraceId: stackTraceId
                    }
                    this.send("getStackTrace", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        pause(callback := "") {
            try {
                onEnabled(args) {
                    this.send("pause", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        restartFrame(callFrameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        callFrameId: callFrameId
                    }
                    this.send("restartFrame", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resume(callback := "") {
            try {
                onEnabled(args) {
                    this.send("resume", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        searchInContent(scriptId, query, caseSensitive := "", isRegex := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptId: scriptId,
                        query: query,
                        caseSensitive: caseSensitive,
                        isRegex: isRegex
                    }
                    this.send("searchInContent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAsyncCallstackDepth(maxDepth, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        maxDepth: maxDepth
                    }
                    this.send("setAsyncCallstackDepth", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBreakpoint(location, condition := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        location: location,
                        condition: condition
                    }
                    this.send("setBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBreakpointByUrl(lineNumber, url, urlRegex := "", columnNumber := "", condition := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        lineNumber: lineNumber,
                        url: url,
                        urlRegex: urlRegex,
                        columnNumber: columnNumber,
                        condition: condition
                    }
                    this.send("setBreakpointByUrl", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBreakpointsActive(active, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        active: active
                    }
                    this.send("setBreakpointsActive", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setInstrumentationBreakpoint(breakpointName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        breakpointName: breakpointName
                    }
                    this.send("setInstrumentationBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setPauseOnExceptions(state, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        state: state
                    }
                    this.send("setPauseOnExceptions", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setscriptsource(scriptId, scriptSource, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptId: scriptId,
                        scriptSource: scriptSource
                    }
                    this.send("setscriptsource", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setskipAllPauses(skip, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        skip: skip
                    }
                    this.send("setskipAllPauses", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setVariableValue(scopeNumber, variableName, newValue, callFrameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scopeNumber: scopeNumber,
                        variableName: variableName,
                        newValue: newValue,
                        callFrameId: callFrameId
                    }
                    this.send("setVariableValue", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stepInto(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stepInto", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stepOut(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stepOut", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stepOver(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stepOver", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getWasmBytecode(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getWasmBytecode", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dissaembleWasmModule(callback := "") {
            try {
                onEnabled(args) {
                    this.send("dissaembleWasmModule", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getStackTraceAsync(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("getStackTraceAsync", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        nextWasmDisassemblyChunk(callback := "") {
            try {
                onEnabled(args) {
                    this.send("nextWasmDisassemblyChunk", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBlackboxedRanges(scriptId, positions, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptId: scriptId,
                        positions: positions
                    }
                    this.send("setBlackboxedRanges", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBlackboxPatterns(patterns, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        patterns: patterns
                    }
                    this.send("setBlackboxPatterns", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBreakpointOnFunctionCall(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("setBreakpointOnFunctionCall", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setReturnValue(callback := "") {
            try {
                onEnabled(args) {
                    this.send("setReturnValue", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        pauseOnAsyncCall(callback := "") {
            try {
                onEnabled(args) {
                    this.send("pauseOnAsyncCall", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        breakpointResolved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("breakpointResolved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        paused(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("paused", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resumed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("resumed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        scriptFailedToParse(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("scriptFailedToParse", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        scriptParsed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("scriptParsed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        ;         Debugger.getWasmBytecode DEPRECATED
        ; Debugger.disassembleWasmModule EXPERIMENTAL
        ; Debugger.getStackTrace EXPERIMENTAL
        ; Debugger.nextWasmDisassemblyChunk EXPERIMENTAL
        ; Debugger.setBlackboxedRanges EXPERIMENTAL
        ; Debugger.setBlackboxPatterns EXPERIMENTAL
        ; Debugger.setBreakpointOnFunctionCall EXPERIMENTAL
        ; Debugger.setReturnValue EXPERIMENTAL
        ; Debugger.pauseOnAsyncCall EXPERIMENTALDEPRECATED
    }


    class DeviceAccess extends DevToolsProtocol.Base {


        cancelPrompt(callback := "") {
            try {
                onEnabled(args) {
                    this.send("cancelPrompt", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        selectPrompt(promptId, accept := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        promptId: promptId,
                        accept: accept
                    }
                    this.send("selectPrompt", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        deviceRequestPrompted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("deviceRequestPrompted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        ;     Methods
        ; DeviceAccess.cancelPrompt
        ; DeviceAccess.disable
        ; DeviceAccess.enable
        ; DeviceAccess.selectPrompt
        ; Events
        ; DeviceAccess.deviceRequestPrompted

    }

    class DeviceOrientation extends DevToolsProtocol.Base {


        clearDeviceOrientationOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearDeviceOrientationOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDeviceOrientationOverride(alpha, beta, gamma, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        alpha: alpha,
                        beta: beta,
                        gamma: gamma
                    }
                    this.send("setDeviceOrientationOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        ;     Methods
        ; DeviceOrientation.clearDeviceOrientationOverride
        ; DeviceOrientation.setDeviceOrientationOverride

    }

    class DOM extends DevToolsProtocol.Base {

        ;  REQUIRED for endpoint registration for the class to interface with
        __New(a, b) {
            this.register({
                getNodeForLocation: ObjBindMethod(this, "getNodeForLocation"),
                ; highlightNode: ObjBindMethod(this, "highlightNode"),
                getOuterHTML: ObjBindMethod(this, "getOuterHTML")
                
            })
            super.__New(a, b)           
        }

        describeNode(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("describeNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        focus(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("focus", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getAttributes(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getAttributes", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getBoxModel(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getBoxModel", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getDocument(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getDocument", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getNodeForLocation(x, y, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        x: x,
                        y: y
                    }
                    this.send("getNodeForLocation", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getOuterHTML(nodeId, backendNodeId, objectId,  callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        backendNodeId: backendNodeId,
                        objectId: objectId
                    }
                    this.send("getOuterHTML", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        hidehighlight(callback := "") {
            try {
                onEnabled(args) {
                    this.send("hidehighlight", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        highlightNode(nodeId, highlightConfig, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        highlightConfig: highlightConfig
                    }
                    this.send("highlightNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        highlightRect(x, y, width, height, color, outlineColor := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        x: x,
                        y: y,
                        width: width,
                        height: height,
                        color: color,
                        outlineColor: outlineColor
                    }
                    this.send("highlightRect", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        moveTo(x, y, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        x: x,
                        y: y
                    }
                    this.send("moveTo", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        querySelector(nodeId, selector, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        selector: selector
                    }
                    this.send("querySelector", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        querySelectorAll(nodeId, selector, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        selector: selector
                    }
                    this.send("querySelectorAll", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeAttribute(nodeId, name, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        name: name
                    }
                    this.send("removeAttribute", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeNode(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("removeNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestChildNodes(nodeId, depth := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        depth: depth
                    }
                    this.send("requestChildNodes", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestNode(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("requestNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resolveNode(nodeId, objectGroup := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        objectGroup: objectGroup
                    }
                    this.send("resolveNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        scrollIntoViewIfNeeded(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("scrollIntoViewIfNeeded", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAttributesAsText(nodeId, text, name := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        text: text,
                        name: name
                    }
                    this.send("setAttributesAsText", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAttributeValue(nodeId, name, value, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        name: name,
                        value: value
                    }
                    this.send("setAttributeValue", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setFileInputFiles(files, nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        files: files,
                        nodeId: nodeId
                    }
                    this.send("setFileInputFiles", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setNodeName(nodeId, name, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        name: name
                    }
                    this.send("setNodeName", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setNodeValue(nodeId, value, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        value: value
                    }
                    this.send("setNodeValue", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setOuterHTML(nodeId, outerHTML, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        outerHTML: outerHTML
                    }
                    this.send("setOuterHTML", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getFlattenedDocument(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getFlattenedDocument", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        collectclassNamesFromSubtree(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("collectclassNamesFromSubtree", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        copyTo(nodeId, targetNodeId, insertBeforeNodeId := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        targetNodeId: targetNodeId,
                        insertBeforeNodeId: insertBeforeNodeId
                    }
                    this.send("copyTo", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        discardSearchResults(callback := "") {
            try {
                onEnabled(args) {
                    this.send("discardSearchResults", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getContainerForNode(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getContainerForNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getContentQuads(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getContentQuads", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getElementByRelation(nodeId, relation, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        relation: relation
                    }
                    this.send("getElementByRelation", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getFileInfo(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("getFileInfo", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getFrameOwner(frameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId
                    }
                    this.send("getFrameOwner", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getNodesForSubtreeByStyle(nodeId, computedStyles, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        computedStyles: computedStyles
                    }
                    this.send("getNodesForSubtreeByStyle", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getNodeStackTraces(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getNodeStackTraces", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getQueryingDescendantsForContainer(nodeId, containerName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        containerName: containerName
                    }
                    this.send("getQueryingDescendantsForContainer", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getRelayoutBoundary(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getRelayoutBoundary", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getSearchResults(searchId, fromIndex, toIndex, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        searchId: searchId,
                        fromIndex: fromIndex,
                        toIndex: toIndex
                    }
                    this.send("getSearchResults", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getTopLayerElements(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getTopLayerElements", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        markundoableState(callback := "") {
            try {
                onEnabled(args) {
                    this.send("markundoableState", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        performSearch(query, includeUserAgentShadowDOM, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        query: query,
                        includeUserAgentShadowDOM: includeUserAgentShadowDOM
                    }
                    this.send("performSearch", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        pushNodeBypathToFrontend(path, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        path: path
                    }
                    this.send("pushNodeBypathToFrontend", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        pushNodesByBackendIdsToFrontend(nodeIds, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeIds: nodeIds
                    }
                    this.send("pushNodesByBackendIdsToFrontend", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        redo(callback := "") {
            try {
                onEnabled(args) {
                    this.send("redo", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setInspectedNode(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("setInspectedNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setNodestackTracesEnabled(enable, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enable: enable
                    }
                    this.send("setNodestackTracesEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        undo(callback := "") {
            try {
                onEnabled(args) {
                    this.send("undo", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        attributeModified(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("attributeModified", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        attributeRemoved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("attributeRemoved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        characterDataModified(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("characterDataModified", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        childNodecountUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("childNodecountUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        childNodeInserted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("childNodeInserted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        childNodeRemoved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("childNodeRemoved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        documentUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("documentUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setChildNodes(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("setChildNodes", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        distributedNodesUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("distributedNodesUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        inlineStyleinvalidated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("inlineStyleinvalidated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        pseudoElementAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("pseudoElementAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        pseudoElementRemoved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("pseudoElementRemoved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        shadowRootPopped(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("shadowRootPopped", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        shadowRootPushed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("shadowRootPushed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        topLayerElementsUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("topLayerElementsUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class DOMDebugger extends DevToolsProtocol.Base {


        getEventListeners(objectId, depth := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId,
                        depth: depth
                    }
                    this.send("getEventListeners", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeDOMBreakpoint(nodeId, type, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        type: type
                    }
                    this.send("removeDOMBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeEventListenerBreakpoint(eventName, targetName := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        eventName: eventName,
                        targetName: targetName
                    }
                    this.send("removeEventListenerBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeXHrBreakpoint(url, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url
                    }
                    this.send("removeXHrBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDOMBreakpoint(nodeId, type, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId,
                        type: type
                    }
                    this.send("setDOMBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setEventListenerBreakpoint(eventName, targetName := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        eventName: eventName,
                        targetName: targetName
                    }
                    this.send("setEventListenerBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setXHRBreakpoint(url, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url
                    }
                    this.send("setXHRBreakpoint", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBreakOnCsPViolation(callback := "") {
            try {
                onEnabled(args) {
                    this.send("setBreakOnCsPViolation", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeInstrumentationBreakpoint(callback := "") {
            try {
                onEnabled(args) {
                    this.send("removeInstrumentationBreakpoint", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setInstrumentationBreakpoint(callback := "") {
            try {
                onEnabled(args) {
                    this.send("setInstrumentationBreakpoint", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }
    }


    class DOMSnapshot extends DevToolsProtocol.Base {


        captureSnapshot(callback := "") {
            try {
                onEnabled(args) {
                    this.send("captureSnapshot", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getSnapshot(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getSnapshot", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class DOMStorage extends DevToolsProtocol.Base {


        clear(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clear", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        getDOMStorageItems(storageId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        storageId: storageId
                    }
                    this.send("getDOMStorageItems", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeDOMStorageItem(storageId, key, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        storageId: storageId,
                        key: key
                    }
                    this.send("removeDOMStorageItem", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDOMstorageItem(storageId, key, value, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        storageId: storageId,
                        key: key,
                        value: value
                    }
                    this.send("setDOMstorageItem", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dOMStorageItemAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dOMStorageItemAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dOMStorageItemRemoved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dOMStorageItemRemoved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dOMStorageItemscleared(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dOMStorageItemscleared", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dOMStorageItemUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dOMStorageItemUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Emulation extends DevToolsProtocol.Base {


        clearDevicemetricsOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearDevicemetricsOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearGeolocationOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearGeolocationOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearIdleOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearIdleOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setCPUThrottlingRate(rate, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        rate: rate
                    }
                    this.send("setCPUThrottlingRate", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDefaultBackgroundColorOverride(color := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        color: color
                    }
                    this.send("setDefaultBackgroundColorOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDevicemetricsOverride(width, height, deviceScaleFactor, mobile := "", scale := "", screenWidth := "", screenHeight := "", positionX := "", positionY := "", dontsetVisiblesize := "", screenOrientation := "", viewport := "", displayFeature := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        width: width,
                        height: height,
                        deviceScaleFactor: deviceScaleFactor,
                        mobile: mobile,
                        scale: scale,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        positionX: positionX,
                        positionY: positionY,
                        dontsetVisiblesize: dontsetVisiblesize,
                        screenOrientation: screenOrientation,
                        viewport: viewport,
                        displayFeature: displayFeature
                    }
                    this.send("setDevicemetricsOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setEmulatedMedia(media, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        media: media
                    }
                    this.send("setEmulatedMedia", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setEmulatedVisionDeficiency(type, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        type: type
                    }
                    this.send("setEmulatedVisionDeficiency", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setGeolocationOverride(latitude, longitude, accuracy := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        latitude: latitude,
                        longitude: longitude,
                        accuracy: accuracy
                    }
                    this.send("setGeolocationOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setIdleOverride(isUserActive, isScreenUnlocked, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        isUserActive: isUserActive,
                        isScreenUnlocked: isScreenUnlocked
                    }
                    this.send("setIdleOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setscriptExecutionDisabled(value, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        value: value
                    }
                    this.send("setscriptExecutionDisabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setTimezoneOverride(timezoneId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        timezoneId: timezoneId
                    }
                    this.send("setTimezoneOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setTouchEmulationEnabled(enabled, configuration := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled,
                        configuration: configuration
                    }
                    this.send("setTouchEmulationEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setUserAgentOverride(userAgent, acceptLanguage := "", platform := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        userAgent: userAgent,
                        acceptLanguage: acceptLanguage,
                        platform: platform
                    }
                    this.send("setUserAgentOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        canEmulate(callback := "") {
            try {
                onEnabled(args) {
                    this.send("canEmulate", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearDevicePostureOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearDevicePostureOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getOverriddenSensorInformation(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getOverriddenSensorInformation", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resetPagescaleFactor(callback := "") {
            try {
                onEnabled(args) {
                    this.send("resetPagescaleFactor", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAutoDarkModeOverride(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setAutoDarkModeOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAutomationOverride(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setAutomationOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDevicePostureOverride(posture, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        posture: posture
                    }
                    this.send("setDevicePostureOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDisabledImageTypes(imageTypes, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        imageTypes: imageTypes
                    }
                    this.send("setDisabledImageTypes", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDocumentCookieDisabled(disabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        disabled: disabled
                    }
                    this.send("setDocumentCookieDisabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setEmitTouchEventsForMouse(enabled, configuration := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled,
                        configuration: configuration
                    }
                    this.send("setEmitTouchEventsForMouse", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setFocusEmulationEnabled(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setFocusEmulationEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setHardwareConcurrencyOverride(threads, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        threads: threads
                    }
                    this.send("setHardwareConcurrencyOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setLocaleOverride(locale, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        locale: locale
                    }
                    this.send("setLocaleOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setPagescaleFactor(pageScaleFactor, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        pageScaleFactor: pageScaleFactor
                    }
                    this.send("setPagescaleFactor", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setscrollbarsHidden(hidden, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        hidden: hidden
                    }
                    this.send("setscrollbarsHidden", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setsensorOverrideEnabled(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setsensorOverrideEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setsensorOverridereadings(acceleration, rotationRate, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        acceleration: acceleration,
                        rotationRate: rotationRate
                    }
                    this.send("setsensorOverridereadings", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setVirtualTimePolicy(policy, budget := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        policy: policy,
                        budget: budget
                    }
                    this.send("setVirtualTimePolicy", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setNavigatorOverrides(overrides, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        overrides: overrides
                    }
                    this.send("setNavigatorOverrides", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setVisiblesize(width, height, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        width: width,
                        height: height
                    }
                    this.send("setVisiblesize", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        virtualTimeBudgetExpired(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("virtualTimeBudgetExpired", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class EventBreakpoints extends DevToolsProtocol.Base {


        setInstrumentationBreakpoint(callback := "") {
            try {
                onEnabled(args) {
                    this.send("setInstrumentationBreakpoint", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeInstrumentationBreakpoint(callback := "") {
            try {
                onEnabled(args) {
                    this.send("removeInstrumentationBreakpoint", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class FedCm extends DevToolsProtocol.Base {


        clickDialogButton(buttonId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        buttonId: buttonId
                    }
                    this.send("clickDialogButton", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dismissdialog(callback := "") {
            try {
                onEnabled(args) {
                    this.send("dismissdialog", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        openUrl(url, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url
                    }
                    this.send("openUrl", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resetCooldown(callback := "") {
            try {
                onEnabled(args) {
                    this.send("resetCooldown", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        selectAccount(account, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        account: account
                    }
                    this.send("selectAccount", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dialogclosed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dialogclosed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dialogShown(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dialogShown", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }


    class FetchCustom extends DevToolsProtocol.Fetch {

        __New(wv2, console) {
            this.register({
                onFetchIdle: ObjBindMethod(this, "fetchWatch")
            })
            super.__New(wv2, console)           
        }

        ;;REVIEW NETWORK DOMAIN FOR INTEDED FUNCTIOBALITY IDLE
        fetchWatch(callback) {
            this.idleTimer := Timer(5000, 100, this.console)

            this.idleTimer.on(this.idleTimer.events["alarm"], alramHandler)
            alramHandler(a) {
                callback.call(a)
            }

            this.requestPaused(requestPausedHandler)
            requestPausedHandler(args) {
                this.getResponseBody(args.requestId, getResponseBodyHandler)
                getResponseBodyHandler(a) {
                    this.idleTimer.Reset()
                    this.continueRequest(args.requestId)  ;, continueRequestHandler
                    continueRequestHandler(a) {                            
                    }
                }
            }
        }
    }

    class Fetch extends DevToolsProtocol.Base {

        __New(a, b) {
            this.register({
                fGetResponseBody: ObjBindMethod(this, "getResponseBody")
            })
            super.__New(a, b)           
        }

        continueRequest(requestId, url := "", method := "", postData := "", headers := "", hasPostData := "", rawResponse := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId,
                        url: url,
                        method: method,
                        postData: postData,
                        headers: headers,
                        hasPostData: hasPostData,
                        rawResponse: rawResponse
                    }
                    this.send("continueRequest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        failRequest(requestId, errorReason, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId,
                        errorReason: errorReason
                    }
                    this.send("failRequest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        fulfillRequest(requestId, responseCode, responseHeaders, binaryResponse := "", responsePhrase := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId,
                        responseCode: responseCode,
                        responseHeaders: responseHeaders,
                        binaryResponse: binaryResponse,
                        responsePhrase: responsePhrase
                    }
                    this.send("fulfillRequest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getResponseBody(requestId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId
                    }
                    this.send("getResponseBody", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        takeResponseBodyForInterceptionAsStream(requestId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId
                    }
                    this.send("takeResponseBodyForInterceptionAsStream", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        continueWithAuth(authChallengeResponse, requestId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        authChallengeResponse: authChallengeResponse,
                        requestId: requestId
                    }
                    this.send("continueWithAuth", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestPaused(callback := "") {
            try {
                onEnabled(args) {

                    ; this.on("requestPaused", requestPausedHandler)
                    ; requestPausedHandler(args) {
                    ;     this.idleTimer.Reset()
                    ; }

                    this.idleTimer.start()
                    this.receive("requestPaused", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        authRequired(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("authRequired", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestWillBeSent(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("requestWillBeSent", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        responsereceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("responsereceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadingFinished(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("loadingFinished", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadingFailed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("loadingFailed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }


    class HeadlessExperimental extends DevToolsProtocol.Base {

        beginFrame(callback := "") {
            try {
                onEnabled(args) {
                    this.send("beginFrame", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class HeapProfiler extends DevToolsProtocol.Base {


        addInspectedHeapObject(heapObjectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        heapObjectId: heapObjectId
                    }
                    this.send("addInspectedHeapObject", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        collectGarbage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("collectGarbage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getHeapObjectId(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("getHeapObjectId", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getObjectByHeapObjectId(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("getObjectByHeapObjectId", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getSamplingProfile(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getSamplingProfile", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startsampling(samplingInterval, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        samplingInterval: samplingInterval
                    }
                    this.send("startsampling", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startTrackingHeapObjects(trackAllocations := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        trackAllocations: trackAllocations
                    }
                    this.send("startTrackingHeapObjects", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopsampling(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopsampling", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopTrackingHeapObjects(reportProgress := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        reportProgress: reportProgress
                    }
                    this.send("stopTrackingHeapObjects", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        takeHeapSnapshot(reportProgress := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        reportProgress: reportProgress
                    }
                    this.send("takeHeapSnapshot", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        lastSeenObjectId(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("lastSeenObjectId", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        reportHeapSnapshotProgress(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("reportHeapSnapshotProgress", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resetProfiles(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("resetProfiles", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        addHeapSnapshotChunk(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("addHeapSnapshotChunk", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        heapStatsUpdate(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("heapStatsUpdate", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class IndexedDB extends DevToolsProtocol.Base {


        clearObjectStore(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearObjectStore", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        deletedatabase(callback := "") {
            try {
                onEnabled(args) {
                    this.send("deletedatabase", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        deleteObjectStoreEntries(objectStoreName, keyRange := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectStoreName: objectStoreName,
                        keyRange: keyRange
                    }
                    this.send("deleteObjectStoreEntries", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getMetadata(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getMetadata", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestData(callback := "") {
            try {
                onEnabled(args) {
                    this.send("requestData", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestDatabase(callback := "") {
            try {
                onEnabled(args) {
                    this.send("requestDatabase", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestDatabaseNames(callback := "") {
            try {
                onEnabled(args) {
                    this.send("requestDatabaseNames", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Input extends DevToolsProtocol.Base {


        dispatchKeyEvent(type, modifiers, timestamp, text := "", unmodifiedText := "", keyIdentifier := "", code := "", key := "", windowsVirtualKeyCode := "", nativeVirtualKeyCode := "", autoRepeat := "", isKeypad := "", isSystemKey := "", location := "", commands := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        type: type,
                        modifiers: modifiers,
                        timestamp: timestamp,
                        text: text,
                        unmodifiedText: unmodifiedText,
                        keyIdentifier: keyIdentifier,
                        code: code,
                        key: key,
                        windowsVirtualKeyCode: windowsVirtualKeyCode,
                        nativeVirtualKeyCode: nativeVirtualKeyCode,
                        autoRepeat: autoRepeat,
                        isKeypad: isKeypad,
                        isSystemKey: isSystemKey,
                        location: location,
                        commands: commands
                    }
                    this.send("dispatchKeyEvent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dispatchMouseEvent(type, x, y, modifiers, timestamp, button := "", buttons := "", clickCount := "", force := "", tangentialPressure := "", tiltX := "", tiltY := "", twist := "", deltaX := "", deltaY := "", pointerType := "", pointerId := "", originalPointerType := "", originalPointId := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        type: type,
                        x: x,
                        y: y,
                        modifiers: modifiers,
                        timestamp: timestamp,
                        button: button,
                        buttons: buttons,
                        clickCount: clickCount,
                        force: force,
                        tangentialPressure: tangentialPressure,
                        tiltX: tiltX,
                        tiltY: tiltY,
                        twist: twist,
                        deltaX: deltaX,
                        deltaY: deltaY,
                        pointerType: pointerType,
                        pointerId: pointerId,
                        originalPointerType: originalPointerType,
                        originalPointId: originalPointId
                    }
                    this.send("dispatchMouseEvent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dispatchTouchEvent(type, touchPoints, modifiers, timestamp, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        type: type,
                        touchPoints: touchPoints,
                        modifiers: modifiers,
                        timestamp: timestamp
                    }
                    this.send("dispatchTouchEvent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        emulateTouchFromMouseevent(type, x, y, button, timestamp, deltaX := "", deltaY := "", modifiers := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        type: type,
                        x: x,
                        y: y,
                        button: button,
                        timestamp: timestamp,
                        deltaX: deltaX,
                        deltaY: deltaY,
                        modifiers: modifiers
                    }
                    this.send("emulateTouchFromMouseevent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        synthesizePinchGesture(x, y, scaleFactor, relativeSpeed := "", gestureSourceType := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        x: x,
                        y: y,
                        scaleFactor: scaleFactor,
                        relativeSpeed: relativeSpeed,
                        gestureSourceType: gestureSourceType
                    }
                    this.send("synthesizePinchGesture", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        synthesizescrollGesture(x, y, xDistance, yDistance, xOverscroll := "", yOverscroll := "", preventFling := "", speed := "", gestureSourceType := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        x: x,
                        y: y,
                        xDistance: xDistance,
                        yDistance: yDistance,
                        xOverscroll: xOverscroll,
                        yOverscroll: yOverscroll,
                        preventFling: preventFling,
                        speed: speed,
                        gestureSourceType: gestureSourceType
                    }
                    this.send("synthesizescrollGesture", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        synthesizeTapGesture(x, y, duration := "", tapCount := "", gestureSourceType := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        x: x,
                        y: y,
                        duration: duration,
                        tapCount: tapCount,
                        gestureSourceType: gestureSourceType
                    }
                    this.send("synthesizeTapGesture", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dragIntercepted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dragIntercepted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        touchEventFired(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("touchEventFired", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Inspector extends DevToolsProtocol.Base {


        evaluateOnCallFrame(callFrameId, expression, objectGroup := "", includeCommandLineAPI := "", silent := "", returnByValue := "", generatePreview := "", throwOnSideEffect := "", timeout := "", disableBreaks := "", replMode := "", allowUnsafeEvalBlockedByCSP := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        callFrameId: callFrameId,
                        expression: expression,
                        objectGroup: objectGroup,
                        includeCommandLineAPI: includeCommandLineAPI,
                        silent: silent,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        throwOnSideEffect: throwOnSideEffect,
                        timeout: timeout,
                        disableBreaks: disableBreaks,
                        replMode: replMode,
                        allowUnsafeEvalBlockedByCSP: allowUnsafeEvalBlockedByCSP
                    }
                    this.send("evaluateOnCallFrame", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        callFunctionOn(objectId, functionDeclaration, arguments := "", silent := "", returnByValue := "", generatePreview := "", userGesture := "", awaitPromise := "", executionContextId := "", objectGroup := "", includeCommandLineAPI := "", doNotpauseOnExceptionsAndMuteConsole := "", returnByValuePrefix := "", generatePreviewPrefix := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId,
                        functionDeclaration: functionDeclaration,
                        arguments: arguments,
                        silent: silent,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        userGesture: userGesture,
                        awaitPromise: awaitPromise,
                        executionContextId: executionContextId,
                        objectGroup: objectGroup,
                        includeCommandLineAPI: includeCommandLineAPI,
                        doNotpauseOnExceptionsAndMuteConsole: doNotpauseOnExceptionsAndMuteConsole,
                        returnByValuePrefix: returnByValuePrefix,
                        generatePreviewPrefix: generatePreviewPrefix
                    }
                    this.send("callFunctionOn", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getProperties(objectId, ownProperties := "", accessorPropertiesOnly := "", generatePreview := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId,
                        ownProperties: ownProperties,
                        accessorPropertiesOnly: accessorPropertiesOnly,
                        generatePreview: generatePreview
                    }
                    this.send("getProperties", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        releaseObject(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("releaseObject", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        releaseObjectGroup(objectGroup, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectGroup: objectGroup
                    }
                    this.send("releaseObjectGroup", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

    }

    class IO extends DevToolsProtocol.Base {

        close(callback := "") {
            try {
                onEnabled(args) {
                    this.send("close", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        read(callback := "") {
            try {
                onEnabled(args) {
                    this.send("read", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resolveBlob(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("resolveBlob", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        write(data, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        data: data
                    }
                    this.send("write", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dataAvailable(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dataAvailable", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class LayerTree extends DevToolsProtocol.Base {


        compositingReasons(callback := "") {
            try {
                onEnabled(args) {
                    this.send("compositingReasons", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        disablePainting(callback := "") {
            try {
                onEnabled(args) {
                    this.send("disablePainting", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        enablePainting(callback := "") {
            try {
                onEnabled(args) {
                    this.send("enablePainting", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadSnapshot(tiles := "", snapshotId := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        tiles: tiles,
                        snapshotId: snapshotId
                    }
                    this.send("loadSnapshot", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        makeSnapshot(callback := "") {
            try {
                onEnabled(args) {
                    this.send("makeSnapshot", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        profileSnapshot(callback := "") {
            try {
                onEnabled(args) {
                    this.send("profileSnapshot", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        releaseSnapshot(snapshotId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        snapshotId: snapshotId
                    }
                    this.send("releaseSnapshot", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        replaySnapshot(snapshotId, fromStep := "", toStep := "", scale := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        snapshotId: snapshotId,
                        fromStep: fromStep,
                        toStep: toStep,
                        scale: scale
                    }
                    this.send("replaySnapshot", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        snapshotCommandLog(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("snapshotCommandLog", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        layerPainted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("layerPainted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        layerTreeDidChange(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("layerTreeDidChange", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Log extends DevToolsProtocol.Base {

        __New(a, b) {
            this.register({
                onEntryAdded: ObjBindMethod(this, "entryAdded")
            })
            super.__New(a, b)           
        }
        

        clear(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clear", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startViolationsReport(config := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        config: config
                    }
                    this.send("startViolationsReport", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopViolationsReport(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopViolationsReport", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        entryAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("entryAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class media extends DevToolsProtocol.Base {


        playerErrorsRaised(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("playerErrorsRaised", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        playerEventsAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("playerEventsAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        playerMessagesLogged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("playerMessagesLogged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        playerpropertiesChanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("playerpropertiesChanged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        playersCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("playersCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Memory extends DevToolsProtocol.Base {


        forciblyPurgeJavaScriptMemory(callback := "") {
            try {
                onEnabled(args) {
                    this.send("forciblyPurgeJavaScriptMemory", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getAllTimeSamplingProfile(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getAllTimeSamplingProfile", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getBrowserSamplingProfile(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getBrowserSamplingProfile", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getDOMCounters(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getDOMCounters", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getSamplingProfile(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getSamplingProfile", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        prepareForLeakDetection(callback := "") {
            try {
                onEnabled(args) {
                    this.send("prepareForLeakDetection", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setPressureNotificationssuppressed(suppressed := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        suppressed: suppressed
                    }
                    this.send("setPressureNotificationssuppressed", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        simulatePressureNotification(level, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        level: level
                    }
                    this.send("simulatePressureNotification", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startsampling(samplingInterval, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        samplingInterval: samplingInterval
                    }
                    this.send("startsampling", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopsampling(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopsampling", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Network extends DevToolsProtocol.Base {

        __New(a, b) {

            this.register({
                onDataReceived: ObjBindMethod(this, "dataReceived"),                
                onRsponseReceived: ObjBindMethod(this, "responseReceived"),
                nGetResponseBody: ObjBindMethod(this, "getResponseBody")
            })
            super.__New(a, b)  
            
        }


        clearBrowsercache(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearBrowsercache", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearBrowsercookies(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearBrowsercookies", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        deleteCookies(callback := "") {
            try {
                onEnabled(args) {
                    this.send("deleteCookies", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        emulateNetworkConditions(offline, latency, downloadThroughput, uploadThroughput, connectionType := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        offline: offline,
                        latency: latency,
                        downloadThroughput: downloadThroughput,
                        uploadThroughput: uploadThroughput,
                        connectionType: connectionType
                    }
                    this.send("emulateNetworkConditions", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getCookies(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getCookies", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getRequestPostData(requestId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId
                    }
                    this.send("getRequestPostData", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getResponseBody(requestId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId
                    }
                    this.send("getResponseBody", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBypassserviceWorker(bypass := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        bypass: bypass
                    }
                    this.send("setBypassserviceWorker", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setCacheDisabled(cachedisabled := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cachedisabled: cachedisabled
                    }
                    this.send("setCacheDisabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setCookie(name, value, url, domain := "", path := "", secure := "", httpOnly := "", sameSite := "", expires := "", priority := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        name: name,
                        value: value,
                        url: url,
                        domain: domain,
                        path: path,
                        secure: secure,
                        httpOnly: httpOnly,
                        sameSite: sameSite,
                        expires: expires,
                        priority: priority
                    }
                    this.send("setCookie", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setCookies(cookies, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cookies: cookies
                    }
                    this.send("setCookies", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setExtraHTTPHeaders(headers, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        headers: headers
                    }
                    this.send("setExtraHTTPHeaders", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setUserAgentOverride(userAgent, acceptLanguage := "", platform := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        userAgent: userAgent,
                        acceptLanguage: acceptLanguage,
                        platform: platform
                    }
                    this.send("setUserAgentOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        canclearBrowsercache(callback := "") {
            try {
                onEnabled(args) {
                    this.send("canclearBrowsercache", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        canclearBrowsercookies(callback := "") {
            try {
                onEnabled(args) {
                    this.send("canclearBrowsercookies", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        canEmulateNetworkconditions(callback := "") {
            try {
                onEnabled(args) {
                    this.send("canEmulateNetworkconditions", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getAllCookies(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getAllCookies", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearacceptedEncodingsOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearacceptedEncodingsOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        enableReportingApi(callback := "") {
            try {
                onEnabled(args) {
                    this.send("enableReportingApi", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getCertificate(origin, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        origin: origin
                    }
                    this.send("getCertificate", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getResponseBodyForInterception(interceptionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        interceptionId: interceptionId
                    }
                    this.send("getResponseBodyForInterception", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getSecurityIsolationStatus(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getSecurityIsolationStatus", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadNetworkResource(frameId, url, options := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId,
                        url: url,
                        options: options
                    }
                    this.send("loadNetworkResource", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        replayXHr(interceptionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        interceptionId: interceptionId
                    }
                    this.send("replayXHr", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        searchInResponseBody(requestId, query, caseSensitive := "", isRegex := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        requestId: requestId,
                        query: query,
                        caseSensitive: caseSensitive,
                        isRegex: isRegex
                    }
                    this.send("searchInResponseBody", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setacceptedEncodings(acceptedEncodings, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        acceptedEncodings: acceptedEncodings
                    }
                    this.send("setacceptedEncodings", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAttachDebugstack(value, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        value: value
                    }
                    this.send("setAttachDebugstack", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBlockedURLs(urls, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        urls: urls
                    }
                    this.send("setBlockedURLs", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        streamResourceContent(interceptionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        interceptionId: interceptionId
                    }
                    this.send("streamResourceContent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        takeResponseBodyForInterceptionAsStream(interceptionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        interceptionId: interceptionId
                    }
                    this.send("takeResponseBodyForInterceptionAsStream", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        continueInterceptedRequest(interceptionId, errorReason := "", rawResponse := "", url := "", method := "", postData := "", headers := "", authChallengeResponse := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        interceptionId: interceptionId,
                        errorReason: errorReason,
                        rawResponse: rawResponse,
                        url: url,
                        method: method,
                        postData: postData,
                        headers: headers,
                        authChallengeResponse: authChallengeResponse
                    }
                    this.send("continueInterceptedRequest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setRequestInterception(patterns, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        patterns: patterns
                    }
                    this.send("setRequestInterception", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setRequestInterceptionstage(stage, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        stage: stage
                    }
                    this.send("setRequestInterceptionstage", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dataReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dataReceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        eventSourceMessageReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("eventSourceMessageReceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadingFailed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("loadingFailed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadingFinished(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("loadingFinished", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestServedFromCache(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("requestServedFromCache", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestWillBeSent(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("requestWillBeSent", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        responsereceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("responsereceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketclosed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketclosed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketFrameError(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketFrameError", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketFrameReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketFrameReceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketFrameSent(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketFrameSent", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketHandshakeResponseReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketHandshakeResponseReceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webSocketwillSendHandshakeRequest(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webSocketwillSendHandshakeRequest", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webTransportclosed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webTransportclosed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webTransportConnectionEstablished(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webTransportConnectionEstablished", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        webTransportCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("webTransportCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        reportingApiendpointsChangedForOrigin(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("reportingApiendpointsChangedForOrigin", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        reportingApireportAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("reportingApireportAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        reportingApireportUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("reportingApireportUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestWillBeSentExtraInfo(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("requestWillBeSentExtraInfo", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resourceChangedPriority(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("resourceChangedPriority", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        responsereceivedEarlyHints(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("responsereceivedEarlyHints", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        responsereceivedExtraInfo(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("responsereceivedExtraInfo", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        signedExchangeReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("signedExchangeReceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        subresourceWebBundleInnerResponseError(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("subresourceWebBundleInnerResponseError", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        subresourceWebBundleInnerResponseParsed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("subresourceWebBundleInnerResponseParsed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        subresourceWebBundleMetadataError(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("subresourceWebBundleMetadataError", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        subresourceWebBundleMetadataReceived(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("subresourceWebBundleMetadataReceived", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        trusttokenOperationDone(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("trusttokenOperationDone", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        requestIntercepted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("requestIntercepted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Overlay extends DevToolsProtocol.Base {


        ;  REQUIRED for endpoint registration for the class to interface with
        __New(a, b) {
            ; this.register()
            this.register({
                highlightNode: ObjBindMethod(this, "highlightNode")
            })
            super.__New(a, b)           
        }

        getgridHighlightObjectsForTest(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getgridHighlightObjectsForTest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getHighlightObjectForTest(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getHighlightObjectForTest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getSourceOrderHighlightObjectForTest(nodeId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        nodeId: nodeId
                    }
                    this.send("getSourceOrderHighlightObjectForTest", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        hidehighlight(callback := "") {
            try {
                onEnabled(args) {
                    this.send("hidehighlight", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        highlightNode(highlightConfig, nodeId := "", backendNodeId := "", objectId := "", selector := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        highlightConfig: highlightConfig,
                        nodeId: nodeId,
                        backendNodeId: backendNodeId,
                        objectId: objectId,
                        selector: selector
                    }
                    this.send("highlightNode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        highlightQuad(highlightConfig, quad, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        highlightConfig: highlightConfig,
                        quad: quad
                    }
                    this.send("highlightQuad", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }


            highlightRect(highlightConfig, x, y, width, height, color := "", outlineColor := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            highlightConfig: highlightConfig,
                            x: x,
                            y: y,
                            width: width,
                            height: height,
                            color: color,
                            outlineColor: outlineColor
                        }
                        this.send("highlightRect", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            highlightSourceOrder(sourceOrderConfig, sourceNodeId, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            sourceOrderConfig: sourceOrderConfig,
                            sourceNodeId: sourceNodeId
                        }
                        this.send("highlightSourceOrder", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setInspectMode(mode, highlightConfig := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            mode: mode,
                            highlightConfig: highlightConfig
                        }
                        this.send("setInspectMode", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setPausedInDebuggerMessage(message := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            message: message
                        }
                        this.send("setPausedInDebuggerMessage", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowAdHighlights(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowAdHighlights", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowContainerQueryOverlays(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowContainerQueryOverlays", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowDebugBorders(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowDebugBorders", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowFlexOverlays(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowFlexOverlays", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowFPsCounter(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowFPsCounter", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowGridOverlays(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowGridOverlays", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowHinge(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowHinge", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowIsolatedElements(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowIsolatedElements", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowLayoutshiftRegions(result := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            result: result
                        }
                        this.send("setshowLayoutshiftRegions", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowPaintRects(result := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            result: result
                        }
                        this.send("setshowPaintRects", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowscrollBottleneckRects(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowscrollBottleneckRects", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowscrollsnapOverlays(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowscrollsnapOverlays", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowViewportsizeOnResize(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowViewportsizeOnResize", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowWebVitals(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowWebVitals", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowWindowControlsOverlay(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowWindowControlsOverlay", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            highlightFrame(frameId, contentColor := "", contentOutlineColor := "", contentLabel := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            frameId: frameId,
                            contentColor: contentColor,
                            contentOutlineColor: contentOutlineColor,
                            contentLabel: contentLabel
                        }
                        this.send("highlightFrame", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setshowHitTestBorders(show := "", callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            show: show
                        }
                        this.send("setshowHitTestBorders", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            inspectModeCanceled(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("inspectModeCanceled", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            inspectNodeRequested(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("inspectNodeRequested", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            nodeHighlightRequested(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("nodeHighlightRequested", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            screenshotRequested(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("screenshotRequested", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }


        }
    }

    class Page extends DevToolsProtocol.Base {

        __New(wv2, console) {
            this.register({
                navigate: ObjBindMethod(this, "__navigate"),                    
                onNavigationCOmpleted: ObjBindMethod(this, "loadEventFired")
            })
            super.__New(wv2, console)           
        }

        addScriptToevaluateOnNewDocument(source, worldName := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        source: source,
                        worldName: worldName
                    }
                    this.send("addScriptToevaluateOnNewDocument", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        bringToFront(callback := "") {
            try {
                onEnabled(args) {
                    this.send("bringToFront", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        captureScreenshot(format := "", quality := "", clip := "", fromSurface := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        format: format,
                        quality: quality,
                        clip: clip,
                        fromSurface: fromSurface
                    }
                    this.send("captureScreenshot", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        close(callback := "") {
            try {
                onEnabled(args) {
                    this.send("close", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        createIsolatedWorld(frameId, worldName := "", grantUniveralAccess := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId,
                        worldName: worldName,
                        grantUniveralAccess: grantUniveralAccess
                    }
                    this.send("createIsolatedWorld", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getAppManifest(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getAppManifest", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getFrameTree(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getFrameTree", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getLayoutmetrics(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getLayoutmetrics", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getNavigationHistory(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getNavigationHistory", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        handleJavaScriptDialog(accept := "", promptText := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        accept: accept,
                        promptText: promptText
                    }
                    this.send("handleJavaScriptDialog", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        
        __navigate(url, referrer := "", transitionType := "", frameId := "", referrerPolicy := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url,
                        referrer: referrer,
                        transitionType: transitionType,
                        frameId: frameId,
                        referrerPolicy: referrerPolicy
                    }
                    this.send("navigate", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        navigateToHistoryEntry(entryId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        entryId: entryId
                    }
                    this.send("navigateToHistoryEntry", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        printTopDF(transferMode := "", landscape := "", displayHeaderFooter := "", printBackground := "", scale := "", paperWidth := "", paperHeight := "", marginTop := "", marginBottom := "", marginLeft := "", marginRight := "", pageRanges := "", ignoreInvalidPageRanges := "", headerTemplate := "", footerTemplate := "", preferCSSPageSize := "", transferOptions := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        transferMode: transferMode,
                        landscape: landscape,
                        displayHeaderFooter: displayHeaderFooter,
                        printBackground: printBackground,
                        scale: scale,
                        paperWidth: paperWidth,
                        paperHeight: paperHeight,
                        marginTop: marginTop,
                        marginBottom: marginBottom,
                        marginLeft: marginLeft,
                        marginRight: marginRight,
                        pageRanges: pageRanges,
                        ignoreInvalidPageRanges: ignoreInvalidPageRanges,
                        headerTemplate: headerTemplate,
                        footerTemplate: footerTemplate,
                        preferCSSPageSize: preferCSSPageSize,
                        transferOptions: transferOptions
                    }
                    this.send("printTopDF", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        reload(ignoreCache := "", scriptToevaluateOnLoad := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        ignoreCache: ignoreCache,
                        scriptToevaluateOnLoad: scriptToevaluateOnLoad
                    }
                    this.send("reload", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeScriptToevaluateOnNewDocument(identifier, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        identifier: identifier
                    }
                    this.send("removeScriptToevaluateOnNewDocument", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        resetNavigationHistory(callback := "") {
            try {
                onEnabled(args) {
                    this.send("resetNavigationHistory", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setBypassCsP(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setBypassCsP", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDocumentContent(frameId, html, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId,
                        html: html
                    }
                    this.send("setDocumentContent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setInterceptFileChooserDialog(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setInterceptFileChooserDialog", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setlifecycleEventsEnabled(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setlifecycleEventsEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopLoading(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopLoading", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearGeolocationOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearGeolocationOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setGeolocationOverride(latitude, longitude, accuracy, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        latitude: latitude,
                        longitude: longitude,
                        accuracy: accuracy
                    }
                    this.send("setGeolocationOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        addCompilationCache(url, data, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url,
                        data: data
                    }
                    this.send("addCompilationCache", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        captureSnapshot(callback := "") {
            try {
                onEnabled(args) {
                    this.send("captureSnapshot", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearcompilationcache(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearcompilationcache", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        crash(callback := "") {
            try {
                onEnabled(args) {
                    this.send("crash", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        generateTestReport(message, group := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        message: message,
                        group: group
                    }
                    this.send("generateTestReport", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getAdScriptId(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getAdScriptId", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getAppId(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getAppId", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getInstallabilityErrors(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getInstallabilityErrors", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getOriginTrials(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getOriginTrials", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getPermissionsPolicyState(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getPermissionsPolicyState", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getResourceContent(frameId, url, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId,
                        url: url
                    }
                    this.send("getResourceContent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getResourceTree(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getResourceTree", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        produceCompilationCache(url, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url
                    }
                    this.send("produceCompilationCache", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        screencastFrameAck(sessionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        sessionId: sessionId
                    }
                    this.send("screencastFrameAck", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        searchInResource(frameId, url, query, caseSensitive := "", isRegex := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId,
                        url: url,
                        query: query,
                        caseSensitive: caseSensitive,
                        isRegex: isRegex
                    }
                    this.send("searchInResource", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAdBlockingEnabled(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setAdBlockingEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setFontFamilies(fontFamilies, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        fontFamilies: fontFamilies
                    }
                    this.send("setFontFamilies", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setFontsizes(fontSizes, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        fontSizes: fontSizes
                    }
                    this.send("setFontsizes", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setPrerenderingAllowed(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setPrerenderingAllowed", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setRPHRegistrationMode(mode, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        mode: mode
                    }
                    this.send("setRPHRegistrationMode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setsPCTransactionMode(mode, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        mode: mode
                    }
                    this.send("setsPCTransactionMode", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setWebLifecyclestate(state, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        state: state
                    }
                    this.send("setWebLifecyclestate", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startscreencast(callback := "") {
            try {
                onEnabled(args) {
                    this.send("startscreencast", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopscreencast(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopscreencast", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        waitForDebugger(callback := "") {
            try {
                onEnabled(args) {
                    this.send("waitForDebugger", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        addScriptToevaluateOnLoad(scriptSource, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptSource: scriptSource
                    }
                    this.send("addScriptToevaluateOnLoad", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearDevicemetricsOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearDevicemetricsOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearDeviceOrientationOverride(callback := "") {
            try {
                onEnabled(args) {
                    this.send("clearDeviceOrientationOverride", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        deleteCookie(cookieName, url, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cookieName: cookieName,
                        url: url
                    }
                    this.send("deleteCookie", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getManifestIcons(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getManifestIcons", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeScriptToevaluateOnLoad(identifier, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        identifier: identifier
                    }
                    this.send("removeScriptToevaluateOnLoad", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDevicemetricsOverride(width, height, deviceScaleFactor, mobile := "", scale := "", screenWidth := "", screenHeight := "", positionX := "", positionY := "", dontsetVisiblesize := "", screenOrientation := "", viewport := "", displayFeature := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        width: width,
                        height: height,
                        deviceScaleFactor: deviceScaleFactor,
                        mobile: mobile,
                        scale: scale,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        positionX: positionX,
                        positionY: positionY,
                        dontsetVisiblesize: dontsetVisiblesize,
                        screenOrientation: screenOrientation,
                        viewport: viewport,
                        displayFeature: displayFeature
                    }
                    this.send("setDevicemetricsOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDeviceOrientationOverride(alpha, beta, gamma, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        alpha: alpha,
                        beta: beta,
                        gamma: gamma
                    }
                    this.send("setDeviceOrientationOverride", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDownloadBehavior(behavior, downloadPath := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        behavior: behavior,
                        downloadPath: downloadPath
                    }
                    this.send("setDownloadBehavior", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setTouchEmulationEnabled(enabled, configuration := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled,
                        configuration: configuration
                    }
                    this.send("setTouchEmulationEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startRecording(options, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        options: options
                    }
                    this.send("startRecording", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopRecording(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopRecording", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        domContentEventFired(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("domContentEventFired", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        fileChooserOpened(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("fileChooserOpened", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameAttached(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameAttached", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameDetached(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameDetached", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameNavigated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameNavigated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        interstitialHidden(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("interstitialHidden", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        interstitialShown(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("interstitialShown", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        javascriptDialogClosed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("javascriptDialogClosed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        javascriptDialogOpening(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("javascriptDialogOpening", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        lifecycleEvent(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("lifecycleEvent", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        loadEventFired(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("loadEventFired", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        windowOpen(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("windowOpen", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameClearedScheduledNavigation(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameClearedScheduledNavigation", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameScheduledNavigation(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameScheduledNavigation", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        backForwardCacheNotUsed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("backForwardCacheNotUsed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        compilationcacheProduced(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("compilationcacheProduced", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        documentOpened(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("documentOpened", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameRequestedNavigation(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameRequestedNavigation", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        frameResized(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("frameResized", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        framestartedLoading(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("framestartedLoading", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        framestoppedLoading(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("framestoppedLoading", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        navigatedWithinDocument(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("navigatedWithinDocument", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        screencastFrame(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("screencastFrame", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        screencastVisibilityChanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("screencastVisibilityChanged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        downloadProgress(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("downloadProgress", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        downloadWillBegin(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("downloadWillBegin", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Performance extends DevToolsProtocol.Base {


        getmetrics(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getmetrics", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setTimeDomain(timeDomain, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        timeDomain: timeDomain
                    }
                    this.send("setTimeDomain", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        metrics(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("metrics", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }


    class PerformanceTimeline extends DevToolsProtocol.Base {


        timelineEventAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("timelineEventAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Preload extends DevToolsProtocol.Base {


        prefetchStatusUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("prefetchStatusUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        preloadEnabledStateUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("preloadEnabledStateUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        preloadingAttemptSourcesUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("preloadingAttemptSourcesUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        prerenderStatusUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("prerenderStatusUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        ruleSetremoved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("ruleSetremoved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        ruleSetUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("ruleSetUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Profiler extends DevToolsProtocol.Base {


        getBestEffortCoverage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getBestEffortCoverage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setsamplingInterval(interval, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        interval: interval
                    }
                    this.send("setsamplingInterval", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        start(callback := "") {
            try {
                onEnabled(args) {
                    this.send("start", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startPreciseCoverage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("startPreciseCoverage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stop(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stop", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopPreciseCoverage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopPreciseCoverage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        takePreciseCoverage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("takePreciseCoverage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        consoleProfileFinished(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("consoleProfileFinished", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        consoleProfilestarted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("consoleProfilestarted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        preciseCoverageDeltaUpdate(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("preciseCoverageDeltaUpdate", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Runtime extends DevToolsProtocol.Base {


        addbinding(name, binding, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        name: name,
                        binding: binding
                    }
                    this.send("addbinding", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        awaitPromise(promiseObjectId, returnByValue := "", generatePreview := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        promiseObjectId: promiseObjectId,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview
                    }
                    this.send("awaitPromise", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        callFunctionOn(functionDeclaration, objectId := "", arguments := "", silent := "", returnByValue := "", generatePreview := "", userGesture := "", awaitPromise := "", executionContextId := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        functionDeclaration: functionDeclaration,
                        objectId: objectId,
                        arguments: arguments,
                        silent: silent,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        userGesture: userGesture,
                        awaitPromise: awaitPromise,
                        executionContextId: executionContextId
                    }
                    this.send("callFunctionOn", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        compileScript(expression, sourceURL := "", persistScript := "", executionContextId := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        expression: expression,
                        sourceURL: sourceURL,
                        persistScript: persistScript,
                        executionContextId: executionContextId
                    }
                    this.send("compileScript", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        discardConsoleEntries(callback := "") {
            try {
                onEnabled(args) {
                    this.send("discardConsoleEntries", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        evaluate(expression, objectGroup := "", includeCommandLineAPI := "", silent := "", contextId := "", returnByValue := "", generatePreview := "", userGesture := "", awaitPromise := "", throwOnSideEffect := "", timeout := "", disableBreaks := "", replMode := "", allowUnsafeEvalBlockedByCSP := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        expression: expression,
                        objectGroup: objectGroup,
                        includeCommandLineAPI: includeCommandLineAPI,
                        silent: silent,
                        contextId: contextId,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        userGesture: userGesture,
                        awaitPromise: awaitPromise,
                        throwOnSideEffect: throwOnSideEffect,
                        timeout: timeout,
                        disableBreaks: disableBreaks,
                        replMode: replMode,
                        allowUnsafeEvalBlockedByCSP: allowUnsafeEvalBlockedByCSP
                    }
                    this.send("evaluate", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getProperties(objectId, ownProperties := "", accessorPropertiesOnly := "", generatePreview := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId,
                        ownProperties: ownProperties,
                        accessorPropertiesOnly: accessorPropertiesOnly,
                        generatePreview: generatePreview
                    }
                    this.send("getProperties", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        globalLexicalScopeNames(callback := "") {
            try {
                onEnabled(args) {
                    this.send("globalLexicalScopeNames", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        queryObjects(prototypeObjectId, objectGroup := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        prototypeObjectId: prototypeObjectId,
                        objectGroup: objectGroup
                    }
                    this.send("queryObjects", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        releaseObject(objectId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectId: objectId
                    }
                    this.send("releaseObject", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        releaseObjectGroup(objectGroup, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        objectGroup: objectGroup
                    }
                    this.send("releaseObjectGroup", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removebinding(name, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        name: name
                    }
                    this.send("removebinding", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        runIfWaitingForDebugger(scriptId, executionContextId := "", objectGroup := "", silent := "", includeCommandLineAPI := "", returnByValue := "", generatePreview := "", awaitPromise := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptId: scriptId,
                        executionContextId: executionContextId,
                        objectGroup: objectGroup,
                        silent: silent,
                        includeCommandLineAPI: includeCommandLineAPI,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        awaitPromise: awaitPromise
                    }
                    this.send("runIfWaitingForDebugger", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        runScript(scriptId, executionContextId := "", objectGroup := "", silent := "", includeCommandLineAPI := "", returnByValue := "", generatePreview := "", awaitPromise := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scriptId: scriptId,
                        executionContextId: executionContextId,
                        objectGroup: objectGroup,
                        silent: silent,
                        includeCommandLineAPI: includeCommandLineAPI,
                        returnByValue: returnByValue,
                        generatePreview: generatePreview,
                        awaitPromise: awaitPromise
                    }
                    this.send("runScript", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAsyncCallstackDepth(maxDepth, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        maxDepth: maxDepth
                    }
                    this.send("setAsyncCallstackDepth", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getExceptionDetails(exceptionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        exceptionId: exceptionId
                    }
                    this.send("getExceptionDetails", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getHeapUsage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getHeapUsage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getIsolateId(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getIsolateId", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setCustomObjectFormatterEnabled(enabled, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        enabled: enabled
                    }
                    this.send("setCustomObjectFormatterEnabled", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setMaxCallstacksizeToCapture(size, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        size: size
                    }
                    this.send("setMaxCallstacksizeToCapture", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        terminateExecution(callback := "") {
            try {
                onEnabled(args) {
                    this.send("terminateExecution", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        consoleAPIcalled(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("consoleAPIcalled", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        exceptionRevoked(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("exceptionRevoked", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        exceptionThrown(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("exceptionThrown", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        executioncontextcreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("executioncontextcreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        executionContextDestroyed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("executionContextDestroyed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        executionContextsCleared(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("executionContextsCleared", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        inspectRequested(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("inspectRequested", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        bindingCalled(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("bindingCalled", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Schema extends DevToolsProtocol.Base {


        getDomains(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getDomains", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Security extends DevToolsProtocol.Base {


        setIgnorecertificateErrors(ignore := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        ignore: ignore
                    }
                    this.send("setIgnorecertificateErrors", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setOverridecertificateErrors(override := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        override: override
                    }
                    this.send("setOverridecertificateErrors", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        certificateError(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("certificateError", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        securitystateChanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("securitystateChanged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        visibleSecurityStateChanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("visibleSecurityStateChanged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class ServiceWorker extends DevToolsProtocol.Base {


        deliverPushMessage(registrationId, data, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        registrationId: registrationId,
                        data: data
                    }
                    this.send("deliverPushMessage", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dispatchPeriodicSyncEvent(registrationId, tag, lastChance := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        registrationId: registrationId,
                        tag: tag,
                        lastChance: lastChance
                    }
                    this.send("dispatchPeriodicSyncEvent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dispatchSyncEvent(registrationId, tag, lastChance := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        registrationId: registrationId,
                        tag: tag,
                        lastChance: lastChance
                    }
                    this.send("dispatchSyncEvent", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        inspectWorker(versionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        versionId: versionId
                    }
                    this.send("inspectWorker", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setForceUpdateOnPageLoad(forceUpdateOnPageLoad, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        forceUpdateOnPageLoad: forceUpdateOnPageLoad
                    }
                    this.send("setForceUpdateOnPageLoad", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        skipWaiting(scopeURL, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scopeURL: scopeURL
                    }
                    this.send("skipWaiting", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        startWorker(scopeURL, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scopeURL: scopeURL
                    }
                    this.send("startWorker", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopAllWorkers(callback := "") {
            try {
                onEnabled(args) {
                    this.send("stopAllWorkers", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        stopWorker(versionId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        versionId: versionId
                    }
                    this.send("stopWorker", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        unregister(scopeURL, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scopeURL: scopeURL
                    }
                    this.send("unregister", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        updateRegistration(scopeURL, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        scopeURL: scopeURL
                    }
                    this.send("updateRegistration", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        workerErrorReported(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("workerErrorReported", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        workerRegistrationUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("workerRegistrationUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        workerVersionUpdated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("workerVersionUpdated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Storage extends DevToolsProtocol.Base {


        clearDataForOrigin(origin, storageTypes, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        origin: origin,
                        storageTypes: storageTypes
                    }
                    this.send("clearDataForOrigin", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearDataForStorageKey(storageType, storageKey, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        storageType: storageType,
                        storageKey: storageKey
                    }
                    this.send("clearDataForStorageKey", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getCookies(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getCookies", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getStorageKeyForFrame(frameId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        frameId: frameId
                    }
                    this.send("getStorageKeyForFrame", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getUsageAndQuota(origin, storageTypes, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        origin: origin,
                        storageTypes: storageTypes
                    }
                    this.send("getUsageAndQuota", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setCookies(cookies, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        cookies: cookies
                    }
                    this.send("setCookies", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        trackCacheStorageForOrigin(origin, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        origin: origin
                    }
                    this.send("trackCacheStorageForOrigin", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }


            trackCacheStorageForStorageKey(storageType, storageKey, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            storageType: storageType,
                            storageKey: storageKey
                        }
                        this.send("trackCacheStorageForStorageKey", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            trackIndexedDBForOrigin(origin, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            origin: origin
                        }
                        this.send("trackIndexedDBForOrigin", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            trackIndexedDBForStorageKey(storageType, storageKey, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            storageType: storageType,
                            storageKey: storageKey
                        }
                        this.send("trackIndexedDBForStorageKey", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            untrackCacheStorageForOrigin(origin, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            origin: origin
                        }
                        this.send("untrackCacheStorageForOrigin", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            untrackCacheStorageForStorageKey(storageType, storageKey, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            storageType: storageType,
                            storageKey: storageKey
                        }
                        this.send("untrackCacheStorageForStorageKey", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            untrackIndexedDBForOrigin(origin, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            origin: origin
                        }
                        this.send("untrackIndexedDBForOrigin", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            untrackIndexedDBForStorageKey(storageType, storageKey, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            storageType: storageType,
                            storageKey: storageKey
                        }
                        this.send("untrackIndexedDBForStorageKey", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            clearSharedStorageEntries(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("clearSharedStorageEntries", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            clearTrustTokens(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("clearTrustTokens", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            deleteSharedStorageEntry(entry, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            entry: entry
                        }
                        this.send("deleteSharedStorageEntry", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            deleteStorageBucket(bucket, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            bucket: bucket
                        }
                        this.send("deleteStorageBucket", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            getInterestgroupDetails(group, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            group: group
                        }
                        this.send("getInterestgroupDetails", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            getRelatedWebsiteSets(website, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            website: website
                        }
                        this.send("getRelatedWebsiteSets", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            getSharedStorageEntries(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("getSharedStorageEntries", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            getSharedStorageMetadata(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("getSharedStorageMetadata", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            getTrustTokens(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("getTrustTokens", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            overrideQuotaFororigin(origin, quotaSize, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            origin: origin,
                            quotaSize: quotaSize
                        }
                        this.send("overrideQuotaFororigin", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            resetSharedStorageBudget(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("resetSharedStorageBudget", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            runBounceTrackingMitigations(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("runBounceTrackingMitigations", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            sendPendingAttributionReports(callback := "") {
                try {
                    onEnabled(args) {
                        this.send("sendPendingAttributionReports", {}, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setAttributionReportingLocalTestingMode(enabled, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            enabled: enabled
                        }
                        this.send("setAttributionReportingLocalTestingMode", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setAttributionReportingTracking(enabled, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            enabled: enabled
                        }
                        this.send("setAttributionReportingTracking", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setInterestGroupAuctionTracking(enabled, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            enabled: enabled
                        }
                        this.send("setInterestGroupAuctionTracking", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setInterestGroupTracking(enabled, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            enabled: enabled
                        }
                        this.send("setInterestGroupTracking", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setsharedstorageEntry(entry, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            entry: entry
                        }
                        this.send("setsharedstorageEntry", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setsharedstorageTracking(enabled, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            enabled: enabled
                        }
                        this.send("setsharedstorageTracking", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            setstorageBucketTracking(bucket, enabled, callback := "") {
                try {
                    onEnabled(args) {
                        params := {
                            bucket: bucket,
                            enabled: enabled
                        }
                        this.send("setstorageBucketTracking", params, callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            cacheStoragecontentUpdated(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("cacheStoragecontentUpdated", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            cacheStorageListUpdated(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("cacheStorageListUpdated", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            indexedDBContentUpdated(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("indexedDBContentUpdated", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            indexedDBListUpdated(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("indexedDBListUpdated", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            interestGroupAccessed(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("interestGroupAccessed", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            interestGroupAuctionEventOccurred(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("interestGroupAuctionEventOccurred", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            interestGroupAuctionNetworkRequestCreated(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("interestGroupAuctionNetworkRequestCreated", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            sharedstorageAccessed(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("sharedstorageAccessed", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            storageBucketCreatedOrUpdated(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("storageBucketCreatedOrUpdated", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            storageBucketDeleted(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("storageBucketDeleted", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            attributionReportingSourceRegistered(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("attributionReportingSourceRegistered", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }

            attributionReportingTriggerRegistered(callback := "") {
                try {
                    onEnabled(args) {
                        this.receive("attributionReportingTriggerRegistered", callback)
                    }
                    this.enable(onEnabled)
                } catch Error as e {
                    this.handleError(e)
                }
            }


        }

    }

    class SystemInfo extends DevToolsProtocol.Base {


        getFeatureState(featureName, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        featureName: featureName
                    }
                    this.send("getFeatureState", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getInfo(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getInfo", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getProcessInfo(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getProcessInfo", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Target extends DevToolsProtocol.Base {


        activateTarget(targetId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        targetId: targetId
                    }
                    this.send("activateTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        attachToTarget(targetId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        targetId: targetId
                    }
                    this.send("attachToTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        closeTarget(targetId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        targetId: targetId
                    }
                    this.send("closeTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        createBrowsercontext(callback := "") {
            try {
                onEnabled(args) {
                    this.send("createBrowsercontext", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        createTarget(url, width := "", height := "", browserContextId := "", enablebeginFrameControl := "", newWindow := "", background := "", callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        url: url,
                        width: width,
                        height: height,
                        browserContextId: browserContextId,
                        enablebeginFrameControl: enablebeginFrameControl,
                        newWindow: newWindow,
                        background: background
                    }
                    this.send("createTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        detachFromTarget(targetId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        targetId: targetId
                    }
                    this.send("detachFromTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        disposeBrowserContext(browserContextId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        browserContextId: browserContextId
                    }
                    this.send("disposeBrowserContext", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getBrowserContexts(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getBrowserContexts", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getTargets(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getTargets", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setAutoAttach(autoAttach, waitForDebuggerOnstart, flatten, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        autoAttach: autoAttach,
                        waitForDebuggerOnstart: waitForDebuggerOnstart,
                        flatten: flatten
                    }
                    this.send("setAutoAttach", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setDiscoverTargets(discover, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        discover: discover
                    }
                    this.send("setDiscoverTargets", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        sendMessageToTarget(targetId, message, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        targetId: targetId,
                        message: message
                    }
                    this.send("sendMessageToTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        attachToBrowserTarget(browserContextId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        browserContextId: browserContextId
                    }
                    this.send("attachToBrowserTarget", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        autoattachRelated(callback := "") {
            try {
                onEnabled(args) {
                    this.send("autoattachRelated", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        exposeDevToolsProtocol(callback := "") {
            try {
                onEnabled(args) {
                    this.send("exposeDevToolsProtocol", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getTargetInfo(targetId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        targetId: targetId
                    }
                    this.send("getTargetInfo", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        setRemoteLocations(locations, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        locations: locations
                    }
                    this.send("setRemoteLocations", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        receivedMessageFromTarget(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("receivedMessageFromTarget", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        targetCrashed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("targetCrashed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        targetCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("targetCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        targetDestroyed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("targetDestroyed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        targetInfoChanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("targetInfoChanged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        attachedToTarget(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("attachedToTarget", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        detachedFromTarget(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("detachedFromTarget", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Tethering extends DevToolsProtocol.Base {


        bind(port, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        port: port
                    }
                    this.send("bind", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        unbind(port, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        port: port
                    }
                    this.send("unbind", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        accepted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("accepted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class Tracing extends DevToolsProtocol.Base {


        end(callback := "") {
            try {
                onEnabled(args) {
                    this.send("end", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        start(callback := "") {
            try {
                onEnabled(args) {
                    this.send("start", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        traceBufferUsage(callback := "") {
            try {
                onEnabled(args) {
                    this.send("traceBufferUsage", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        dataCollected(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("dataCollected", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        tracingComplete(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("tracingComplete", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        tracingStarted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("tracingStarted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class WebAudio extends DevToolsProtocol.Base {


        getRealtimeData(callback := "") {
            try {
                onEnabled(args) {
                    this.send("getRealtimeData", {}, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        audioListenerCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("audioListenerCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        audioListenerWillBeDestroyed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("audioListenerWillBeDestroyed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        audioNodeCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("audioNodeCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        audioNodeWillBeDestroyed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("audioNodeWillBeDestroyed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        audioParamCreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("audioParamCreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        audioParamWillBeDestroyed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("audioParamWillBeDestroyed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        contextchanged(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("contextchanged", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        contextcreated(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("contextcreated", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        contextWillBeDestroyed(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("contextWillBeDestroyed", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        nodeParamConnected(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("nodeParamConnected", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        nodeParamDisconnected(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("nodeParamDisconnected", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        nodesConnected(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("nodesConnected", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        nodesDisconnected(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("nodesDisconnected", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

    class WebAuthn extends DevToolsProtocol.Base {

        addCredential(authenticatorId, credential, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        authenticatorId: authenticatorId,
                        credential: credential
                    }
                    this.send("addCredential", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        clearcredentials(authenticatorId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        authenticatorId: authenticatorId
                    }
                    this.send("clearcredentials", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getCredential(authenticatorId, credentialId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        authenticatorId: authenticatorId,
                        credentialId: credentialId
                    }
                    this.send("getCredential", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        getCredentials(authenticatorId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        authenticatorId: authenticatorId
                    }
                    this.send("getCredentials", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        removeCredential(authenticatorId, credentialId, callback := "") {
            try {
                onEnabled(args) {
                    params := {
                        authenticatorId: authenticatorId,
                        credentialId: credentialId
                    }
                    this.send("removeCredential", params, callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        credentialAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("credentialAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        credentialRemoved(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("credentialRemoved", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


        creadentialAdded(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("credentialAdded", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }

        credentialAsserted(callback := "") {
            try {
                onEnabled(args) {
                    this.receive("credentialAsserted", callback)
                }
                this.enable(onEnabled)
            } catch Error as e {
                this.handleError(e)
            }
        }


    }

}
