
class Disk {

    static FileSave(data, name, path) {        
        this.MakeDirIfNotExists(path)
        if(Disk.FileExists(name, path)) {
            Disk.FileDelete(name, path)
        }
        FileAppend(data, path name)
    }

    static FileAppend(file, path, val) {              
        this.MakeDirIfNotExists(path)
        FileAppend(val "`n", path file)
    }

    static FileLoad(name, path) {
        if(!this.FileExists(name, path)) {
            return false
        }
        return FileRead(path name)
    }

    ; static  DirectoryLoad(name, path) {
    ;     if(!this.DirExists(name, path)) {
    ;         return false
    ;     }
    ;     files := []
    ;     Loop path "\" name "\*"     {
    ;         files.Push(A_LoopFileFullPath)
    ;     }
    ;     return files
    ; }

    static MakeDirIfNotExists(path) {
        pathDir := ""
        dirs := StrSplit(path, "/")
        if(dirs.Has(1)) {
            for dir in dirs {
                if(!Disk.DirExists(dir, pathDir)) {
                    DirCreate(pathDir dir)
                }
                pathDir .= dir "/"
            }
        } 
    }

    static RemoveDir(name, path) {
        DirDelete(path name)
    }

    static DirExists(name, path) {
        return DirExist(path name)
    }

    static FileExists(name, path) {
        return FileExist(path name)
    }

    static FileCopy(srcFile, srcPath, tartgetFile, targetPath, overwrite := 0) {
        if(!this.FileExists(srcFile, srcPath)) {            
            return false
        }                  
        this.MakeDirIfNotExists(targetPath)
        FileCopy(srcPath srcFile, targetPath tartgetFile, overwrite)
        return true
    }

    static FileMove(srcFile, srcPath, tartgetFile, targetPath, o := 0) {    
        if(!this.FileExists(srcFile, srcPath)) {            
            return false
        }                    
        this.MakeDirIfNotExists(targetPath)
        FileMove(srcPath srcFile, targetPath tartgetFile, o)
        return true
    }

    static FileDelete(name, path) {
        FileDelete(path name)
    }

    static DirCopy(s, t, o := 0) {
        this.MakeDirIfNotExists(t)
        DirCopy(s, t, o)
    }
}