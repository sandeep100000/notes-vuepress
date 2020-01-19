1>1/* ::
:: by bajins https://www.bajins.com

@ECHO OFF
color 0a
Title GO������� by:bajins.com
:: ���ڸ߿�40*120
REG ADD "HKEY_CURRENT_USER\Console" /t REG_DWORD /v WindowSize /d 0x00280078 /f >nul
:: ��Ļ�������߿�1000*120
REG ADD "HKEY_CURRENT_USER\Console" /t REG_DWORD /v ScreenBufferSize /d 0x03e80078 /f >nul

md "%~dp0$testAdmin$" 2>nul
if not exist "%~dp0$testAdmin$" (
    echo bajins���߱�����Ŀ¼��д��Ȩ��! >&2
    exit /b 1
) else rd "%~dp0$testAdmin$"

:: �����ӳٻ���������չ
setlocal enabledelayedexpansion

:: %~f0 ��ʾ��ǰ�������ľ���·��,ȥ�����ŵ�����·��
cscript -nologo -e:jscript "%~f0" get7z
if not "%errorlevel%" == "0" (
    @cmd /k
    goto :EXIT
)

:: ��Ҫ������ļ����ļ���
set files=pyutils static

:: ˳��ѭ�����������һ��Ϊ��ǰĿ¼
for /f "delims=" %%i in ("%cd%") do set projectName=%%~ni
:: �����ɵ��ļ�������һ���֣���ǰһ���ֽ������
set allList=darwin_386,darwin_amd64,freebsd_386,freebsd_amd64,freebsd_arm,
set allList=%allList%netbsd_386,netbsd_amd64,netbsd_arm,openbsd_386,
set allList=%allList%openbsd_amd64,windows_386.exe,windows_amd64.exe,
set allList=%allList%linux_386,linux_amd64,linux_arm,linux_mips,
set allList=%allList%linux_mips64,linux_mips64le,linux_mipsle,linux_s390x

:: ɾ�����ļ�
for %%i in (%allList%) do (
    set binaryFile=%projectName%_%%i
    :: ����������ļ�������ɾ��
    if exist "!binaryFile!" (
        del !binaryFile!
    )
    set zipName=!binaryFile:.exe=.zip!
    if exist "!zipName!" (
        del !zipName!
    )
    if exist "!binaryFile!.tar" (
        del !binaryFile!.tar
    )
    if exist "!binaryFile!.tar.gz" (
        del !binaryFile!.tar.gz
    )
)

:: ʹ��7zѹ��
for %%i in (%allList%) do (
    set binaryFile=%projectName%_%%i
    :: �������ɶ����������ļ����ָ�����GOOS��GOARCH
    for /f "delims=_ tokens=1,2" %%j in ( "%%i" ) do (
        echo.
        echo.
        echo ::::::::::::::::::::::::::::::::::::::::::
        echo :::::: ����!binaryFile! ::::::
        echo ::::::::::::::::::::::::::::::::::::::::::
        echo.
        set Arch=%%k
        if "%%j" == "windows" (
            set Arch=!Arch:.exe=!
        )
        set GOOS=%%j
        set GOARCH=!Arch!
        echo �����������óɹ���!GOOS!------!GOARCH!
        echo.
        go build -ldflags=-w -i -o !binaryFile!
    )
    :: !!Ϊsetlocal EnableDelayedExpansionȡ������ֵ
    if not exist "!binaryFile!" (
        echo ���ʧ�ܣ��ļ�������
        @cmd /k
    )
    :: �жϱ����ַ������Ƿ�����ַ���
    echo %%i | findstr linux >nul && (
        :: ��7zѹ����tar
        7za a -ttar !binaryFile!.tar %files% !binaryFile!
        :: ��7z��tarѹ����gz
        7za a -tgzip !binaryFile!.tar.gz !binaryFile!.tar
        :: ɾ��tar�ļ�
        del *.tar
    ) || (
        set zipName=!binaryFile:.exe=!
        :: ��7zѹ���ļ�Ϊzip
        7za a !zipName!.zip %files% !binaryFile!
    )
    :: ɾ���������ļ�
    del !binaryFile!
)


goto :EXIT

:EXIT
:: �����ӳٻ���������չ������ִ��
endlocal&exit /b %errorlevel%
*/

// ****************************  JavaScript  *******************************


var Argv = WScript.Arguments;
for (i = 0; i < Argv.length; i++) {
    WScript.StdOut.WriteLine("������" + Argv(i));
}

if (Argv.length > 0) {
    switch (Argv(0)) {
        case "get7z":
            try{
                get7z();
            }catch(e){
                WScript.StdErr.WriteLine(e.message);
                // �������˳�
                WScript.Quit(1);
            }
            break;
        default:
            help();
    }
    // �����˳�
    WScript.Quit(0);
}


/**
 * HTTP����
 *
 * @param method        GET,POST
 * @param url           �����ַ
 * @param dataType      "",text,stream,xml,json
 * @param data          ���ݣ�{key:value}��ʽ
 * @param contentType   ���͵��������ͣ�multipart/form-data��
 * application/x-www-form-urlencoded��Ĭ�ϣ���text/plain
 * @returns {string|Document|any}
 */
function request(method, url, dataType, data, contentType) {
    if (url == "" || url == null || url.length <= 0) {
        throw new Error("����url����Ϊ�գ�");
    }
    if (method == "" || method == null || method.length <= 0) {
        method = "GET";
    } else {
        // ���ַ���ת��Ϊ��д
        method = method.toUpperCase();
    }
    if (contentType == "" || contentType == null || contentType.length <= 0) {
        contentType = "application/x-www-form-unlenconded;charset=utf-8";
    }
    var XMLHTTPVersions = [
        'WinHttp.WinHttpRequest.5.1',
        'WinHttp.WinHttpRequest.5.0',
        'Msxml2.ServerXMLHTTP.6.0',
        'Msxml2.ServerXMLHTTP.5.0',
        'Msxml2.ServerXMLHTTP.4.0',
        'Msxml2.ServerXMLHTTP.3.0',
        'Msxml2.ServerXMLHTTP',
        'MSXML2.XMLHTTP.6.0',
        'MSXML2.XMLHTTP.5.0',
        'MSXML2.XMLHTTP.4.0',
        'MSXML2.XMLHTTP.3.0',
        'MSXML2.XMLHTTP',
        'Microsoft.XMLHTTP'
    ];
    var XMLHTTP;
    for (var i = 0; i < XMLHTTPVersions.length; i++) {
        try {
            XMLHTTP = new ActiveXObject(XMLHTTPVersions[i]);
            break;
        } catch (e) {
            WScript.StdOut.Write(XMLHTTPVersions[i]);
            WScript.StdOut.WriteLine("��" + e.message);
        }
    }

    //������ת����Ϊquerystring��ʽ
    var paramarray = [];
    for (key in data) {
        paramarray.push(key + "=" + data[key]);
    }
    var params = paramarray.join("&");

    switch (method) {
        case "POST":
            // 0�첽��1ͬ��
            XMLHTTP.Open(method, url, 0);
            XMLHTTP.SetRequestHeader("CONTENT-TYPE", contentType);
            XMLHTTP.Send(params);
            break;
        default:
            // Ĭ��GET����
            if (params == "" || params.length == 0 || params == null) {
                // 0�첽��1ͬ��
                XMLHTTP.Open(method, url, 0);
            } else {
                XMLHTTP.Open(method, url + "?" + params, 0);
            }
            XMLHTTP.SetRequestHeader("CONTENT-TYPE", contentType);
            XMLHTTP.Send();
    }

    // ���ַ���ת��ΪСд
    dataType = dataType.toLowerCase();
    switch (dataType) {
        case "text":
            return XMLHTTP.responseText;
            break;
        case "stream":
            return XMLHTTP.responseStream;
            break;
        case "xml":
            return XMLHTTP.responseXML;
            break;
        case "json":
            return eval("(" + XMLHTTP.responseText + ")");
            break;
        default:
            return XMLHTTP.responseBody;
    }
}


/**
 * �����ļ�
 *
 * @param url
 * @param directory �ļ��洢Ŀ¼
 * @param filename  �ļ�����Ϊ��Ĭ�Ͻ�ȡurl�е��ļ���
 * @returns {string}
 */
function download(url, directory, filename) {
    if (url == "" || url == null || url.length <= 0) {
        throw new Error("����url����Ϊ�գ�");
    }
    if (directory == "" || directory == null || directory.length <= 0) {
        throw new Error("�ļ��洢Ŀ¼����Ϊ�գ�");
    }

    var fso = new ActiveXObject("Scripting.FileSystemObject");
    // ���Ŀ¼������
    if (!fso.FolderExists(directory)) {
        // ����Ŀ¼
        var strFolderName = fso.CreateFolder(directory);
    }

    if (filename == "" || filename == null || filename.length <= 0) {
        filename = url.substring(url.lastIndexOf("/") + 1);
        // ȥ���ļ�����������ţ�����֮ǰ�ģ��ַ�
        filename = filename.replace(/^.*(\&|\=|\?|\/)/ig, "");
    }
    var path = directory + "\\" + filename;

    var ADO = new ActiveXObject("ADODB.Stream");
    ADO.Mode = 3;
    ADO.Type = 1;
    ADO.Open();
    ADO.Write(request("GET", url, ""));
    ADO.SaveToFile(path, 2);
    ADO.Close();

    // ����ļ�������
    if (!fso.FileExists(path)) {
        return "";
    }
    return path;
}

/**
 * ��ȡ7-Zip
 *
 */
function get7z() {
    var shell = new ActiveXObject("WScript.shell");
    // ִ��7z�����ж��Ƿ�ִ�гɹ�
    var out = shell.Run("cmd /c 7za", 0, true);
    var directory = "c:\\windows";
    var url = "https://github.com/woytu/woytu.github.io/releases/download/v1.0/7za.exe";
    // ���ִ��ʧ��˵��7z������
    if (out == 1) {
        download(url, directory);
    }
    // ִ��7z�����ж��Ƿ�ִ�гɹ�
    out = shell.Run("cmd /c 7za", 0, true);
    var fso = new ActiveXObject("Scripting.FileSystemObject");
    // ���ִ��ʧ�ܣ������ļ�������
    if (out == 1 || !fso.FileExists(directory + "\\7za.exe")) {
        get7z();
    }
}