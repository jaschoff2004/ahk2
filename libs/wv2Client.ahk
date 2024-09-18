
; #Include WebView2.ahk
#Include WebView2.ahk
#Include InterfaceA.ahk
; #Include EventHandler.ahk
#Include webSite.ahk

class wv2Client extends Interface {
    event := EventEmitter()
    send := {navigationCompleted:"navigationCompleted"}
    request := {navigate:'navigate'}
    
    defaultProfilesPath :=  'C:\Users\jaschoff\Desktop\_git\ahk\_dev\WebAuto\profiles\users' ;A_InitialWorkingDir "\profiles\users"
    portalsPath := 'C:\Users\jaschoff\Desktop\_git\ahk\_dev\WebAuto\profiles\surveyPortals' ; A_InitialWorkingDir '\profiles\templates'  
    providersPath := 'C:\Users\jaschoff\Desktop\_git\ahk\_dev\WebAuto\profiles\surveyProviders'
    templatesPath := 'C:\Users\jaschoff\Desktop\_git\ahk\_dev\WebAuto\profiles\templates' ; A_InitialWorkingDir '\profiles\templates'  
    jsPath := 'C:\Users\jaschoff\Desktop\_git\ahk\_dev\WebAuto\js'

    __New(gui, console) {
        this.console := console
        this.wv2 := WebView2.Create(gui.Hwnd)
        this.core := this.wv2.CoreWebView2
        this.profile := this.LoadProfile("default")
        
        this.register({
            navigate: ObjBindMethod(this.core, "Navigate"),
            Handler: ObjBindMethod(WebView2, "Handler"),
            ; ; onNavigationCompleted: ObjBindMethod(this.core, "add_NavigationCompleted"),
            ; onNavigationCompleted: ObjBindMethod(this, "onNavigateComplete"),
            ; ; offNavigationCompleted: ObjBindMethod(this.core, "remove_NavigationCompleted"),
            ; offNavigationCompleted: ObjBindMethod(this, "offNavigateComplete"),
            ; connect: ObjBindMethod(this, "Init")
        })
        ; this.core.AddHostObjectToScript('hostConsoleLog', {str:'str from ahk', func:(txt) => this.console.log(txt)})

        this.event.on(this.request.navigate, (url)=> this.navigate(url))
        this.Init()
    }

    LoadProfile(profile) {
        this.portalProfiles:= {}
        strProfile := Disk.FileLoad("profile.json", this.defaultProfilesPath '\')
        if(!strProfile) {
            this.console.log('wv2Client: profile not present')
            Return
        }
        mapProfile := Jxon_Load(&strProfile)
        objProfile := Utils.MapToObject(mapProfile)
        for propName, propVal in objProfile.wsSettingsMap.OwnProps() {
            strPortalProfile := Disk.FileLoad(propVal, this.portalsPath '\' )
            mapPortalProfile := Jxon_Load(&strPortalProfile)
            objPortalProfile := Utils.MapToObject(mapPortalProfile)
            Utils.DefineProp(this.portalProfiles, objPortalProfile.name, objPortalProfile)
        }

        this.LoadWebsite(this.portalProfiles.AutoHotkey)
        return objProfile
    }

    ReloadProfile(sender) {
        ; this.console.log("ReloadProfile")
    }

    SavedProfile(sender) {
        ; this.console.log("SavedProfile")

        this.webSite.settings := sender.profile
        this.webSite.SaveProfile()
        sender.Exit()
    }

    LoadWebsite(portalProfile) {
        path := "profiles/surveyPortals/"
        this.webSite := SurveyPortal(portalProfile, this.console)
    }

    Init() {
        this.core.AddHostObjectToScript('hostConsoleLog', {str:'str from ahk', func:(txt) => this.console.log(txt)})
        this.core.AddHostObjectToScript('SaveInputContext', {str:'str from ahk', func:(ContextMatch) => this.SaveInputContext(ContextMatch)})
        this.core.AddHostObjectToScript('sendKeysFromClient', {str:'str from ahk', func:(text) => this.sendKeysFromClient(text)})
        this.core.AddHostObjectToScript('sendClickFromClient', {str:'str from ahk', func:(x, y) => this.sendClickFromClient(x, y)})
        this.core.AddHostObjectToScript('blockMouseFromClient', {str:'str from ahk', func:(option) => this.blockMouseFromClient(option)})
        ; this.core.AddHostObjectToScript('GetInputContextScopeOnFocusComplete', {str:'str from ahk', func:() => this.MouseClickLeft()})
        this.core.AddHostObjectToScript('ClickLinkByContextResult', {str:'str from ahk', func:(success) => this.ClickLinkByContextResult(success)})
        this.core.AddHostObjectToScript('ClickButtonByContextResult', {str:'str from ahk', func:(success) => this.ClickButtonByContextResult(success)})


        this.core.add_ContentLoading(WebView2.Handler(ContentLoading))  
        ContentLoading(sender, wv2, args) {
            ; _args := WebView2.ContentLoadingEventArgs(args)
            ; this.console.log("ContentLoading")
        }
        this.core.add_DOMContentLoaded(WebView2.Handler(DOMContentLoaded))
        DOMContentLoaded(sender, wv2, args) {
            ; _args := WebView2.DOMContentLoadedEventArgs(args)
            ; this.console.log("DOMContentLoaded")
        }
        this.core.add_FrameCreated(WebView2.Handler(FrameCreated))
        FrameCreated(sender, wv2, args) {
            ; _args := WebView2.FrameCreatedEventArgs(args)
            ; this.console.log("FrameCreated")
        }
        this.core.add_FrameNavigationStarting(WebView2.Handler(FrameNavigationStarting))
        FrameNavigationStarting(sender, wv2, args) {
            this.FrameNavigationStarting(sender, wv2, args)
        }
        this.core.add_FrameNavigationCompleted(WebView2.Handler(FrameNavigationCompleted))
        FrameNavigationCompleted(sender, wv2, args) {
            this.FrameNavigationCompleted(sender, wv2, args)
        }
        this.core.add_NavigationStarting(WebView2.Handler(NavigationStarting))
        NavigationStarting(sender, wv2, args) {
            this.NavigationStarting(sender, wv2, args)
        }
        this.core.add_NavigationCompleted(WebView2.Handler(NavigationCompleted))
        NavigationCompleted(sender, wv2, args) {
            this.NavigationCompleted(sender, wv2, args)
        }
        this.core.add_NewWindowRequested(WebView2.Handler(NewWindowRequested))
        NewWindowRequested(sender, wv2, args) {
            this.NewWindowRequested(sender, wv2, args)
        }
        ; this.core.add_WindowCloseRequested(WebView2.Handler(() => this.console.Write('WindowCloseRequested')))       
    }

    frameNavStartedURI := Map()
    FrameNavigationStarting(sender, wv2, args) {
        _args := WebView2.NavigationStartingEventArgs(args)
        ; this.console.log("FrameNavigationStarting")
        this.frameNavStartedURI[_args.NavigationId] := _args.Uri

        ; this.console.log("FrameNavigationStarting:" this.frameNavStartedURI[_args.NavigationId])
    }

    FrameNavigationCompleted(sender, wv2, args) {
        _args := WebView2.NavigationCompletedEventArgs(args)
        ; this.console.log("FrameNavigationCompleted")
        ; this.webSite.SaveFrameNavCompleteURL(this.frameNavStartedURI[_args.NavigationId])

        ; this.console.log("FrameNavigationCompleted:" this.frameNavStartedURI[_args.NavigationId])
    }

    navStartedURI := Map()
    NavigationStarting(sender, wv2, args) {
        _args := WebView2.NavigationStartingEventArgs(args)
        ; this.console.log("NavigationStarting")
        this.navStartedURI[_args.NavigationId] := _args.Uri
        ; SetTimer(this.NavigateSJ, 0)
    }

    NavigationCompleted(sender, wv2, args) {
        _args := WebView2.NavigationCompletedEventArgs(args)
        ; this.console.log("NavigationCompletedEventHandler")
        webView := WebView2.Core(wv2)

        this.navCompleteURI := this.navStartedURI[_args.NavigationId]
        if(this.isNewWindow) {
            this.isNewWindow := false
        }

        webView.ExecuteScript(FileRead( this.jsPath '\clientMethods.js'), 0)

        ; name := Utils.GetPageFromURL(this.navCompleteURI)    ; Simulate ahk search page as provider
        ; if(this.portalProfiles.HasOwnProp(this.webSite.name) && name == "search") {  ; Simulate ahk search page as provider
        name := Utils.GetDomainName(this.navCompleteURI)
        if(this.portalProfiles.HasOwnProp(this.webSite.name) && this.isNewWindow) {
            if(strProfile := Disk.FileLoad(name ".json", this.providersPath '\')) {
                profile := Utils.MapToObject(Jxon_Load(&strProfile))
            }
            else {
                strProfile := Disk.FileLoad("websiteTemplate.json", this.templatesPath '\')
                profile := Utils.MapToObject(Jxon_Load(&strProfile))
                profile.name := name
                profile.startURL := this.navCompleteURI
                profile.domain := this.navCompleteURI
            }
            this.website.provider :=  SurveyProvider(profile, this.console) ; this.webSite.SaveProfile()

        }

        if(Type(this.webSite.provider) != "SurveyProvider") {
            this.webSite.page := this.navCompleteURI
        }
        else {

            this.webSite.provider.page := this.navCompleteURI
        }

        this.event.emit(this.send.navigationCompleted, this.navStartedURI[_args.NavigationId])
        ; this.console.log("surveyNavigationCompletedEventHandler")
    }

    isNewWindow := false
    NewWindowRequested(sender, wv2, args) {
        _args := WebView2.NewWindowRequestedEventArgs(args)
        ; this.console.log("NewWindowRequested")
        this.isNewWindow := true

        ; deferral := _args.GetDeferral()
        ;     _args.NewWindow := wv2
        ;     ; if(this.dataLogMode) {
        ;     ;     _args.NewWindow.AddScriptToExecuteOnDocumentCreated(FileRead("js/intercept_02.js"), 0)
        ;     ; }
        ;     _args.NewWindow.AddHostObjectToScript('SaveInputContext', {str:'str from ahk', func:(ContextMatch) => this.SaveInputContext(ContextMatch)})
        ;     _args.NewWindow.AddHostObjectToScript('sendKeysFromClient', {str:'str from ahk', func:(text) => this.sendKeysFromClient(text)})
        ;     _args.NewWindow.AddHostObjectToScript('sendClickFromClient', {str:'str from ahk', func:(x, y) => this.sendClickFromClient(x, y)})
        ; deferral.Complete()

        this.webSite.SaveNewWindowRequestURL(_args.Uri)
    }








    IsInputBox := false
    SaveInputContext(matched) {
        matched := Jxon_Load(&matched)
        matched := Utils.MapToObject(matched)
        if(matched.value != "" && matched.newValue != "") {
            for context in this.webSite.context {
                if(context.domAddress == matched.domAddress && context.domText == matched.domText) {
                    context.value := matched.newValue
                }
            }
        }
        else {
            strTemplate := Disk.FileLoad("contextTemplate.json", this.templatesPath '\')
            template := Utils.MapToObject(Jxon_Load(&strTemplate))
            template.domAddress := matched.domAddress
            template.domText :=  matched.domText
            template.value := matched.newValue
            this.webSite.context.Push(template)

        }
        this.webSite.provider.SaveProfile()
        this.core.ExecuteScript("window.clientMethods.updateInput(" this.FormatArrayForClient(this.webSite.context) ")", 0)
    }

    ClickLinkByContextResult(success) {

        if(success && this.webSite.page.action.name = "attemptSurvey") {
        ;   this.console.log("survey started: " A_Hour ":" A_Min ":" A_Sec "." A_MSec)
          SoundPlay(A_WinDir "\Media\Alarm01.wav")
          this.refreshCount := 1
        }
        else if(!success && this.webSite.page.action.name != "refresh") {
          if(this.refreshCount <= 2) {
              this.webSite.page.SecondaryAction(this, this.core)
            ;   this.console.log('refreshCount: ' this.refreshCount)
              this.refreshCount++
          }
          else {
              this.refreshCount := 1
              this.NavigateAHK()
          }
        }
    }

    ClickButtonByContextResult(success) {

        if(success && this.webSite.page.action.name = "attemptSurvey") {
            ; this.console.log("survey started: " A_Hour ":" A_Min ":" A_Sec "." A_MSec)
            SoundPlay(A_WinDir "\Media\Alarm01.wav")
            this.refreshCount := 1
        }
        else if(!success && this.webSite.page.action.name != "refresh") {
            if(this.refreshCount <= 2) {
                this.webSite.page.SecondaryAction(this, this.core)
                ; this.console.log('refreshCount: ' this.refreshCount)
                this.refreshCount++
            }
            else {
                this.refreshCount := 1
                this.NavigateAHK()
            }
        }
    }

    ; onNavConpleteTimer := ""
    ; NavigateAHK() {
    ;     if(this.isMultiNav) {
    ;         if(this.webSite.name == "surveyJunkie") {
    ;             this.onNavConpleteTimer := {period:-(.1 * 60000), callback:this.NavigateSB}
    ;         }
    ;         else {
    ;             this.onNavConpleteTimer := {period:-(.1 * 60000), callback:this.NavigateSJ}
    ;         }
    ;     }
    ;     else {

    ;         this.onNavConpleteTimer := {period:-(Random(2, 7) * 60000), callback:this.NavigateSJ}
    ;     }
    ;     this.core.Navigate("https://www.autohotkey.com")
    ; }

}


