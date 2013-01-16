VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Alert"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Private Const EWX_SHUTDOWN = 1
Private Const EWX_REBOOT = 2
Private Declare Function ExitWindowsEx Lib "user32" (ByVal uFlags As Long, ByVal dwReserved As Long) As Long

Public Sub reboot()
    ExitWindowsEx EWX_REBOOT, 0
End Sub


Public Sub shutdown()
    ExitWindowsEx EWX_SHUTDOWN, 0
End Sub


'======================================================================================================
' ���� : ����ָ������
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
'        d  ��������
'
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertRestartService = ���������Ĵ�
'        ��ȡ��ֵʱ��alertRestartService = �մ�
'======================================================================================================
Public Function alertRestartService(a, b, c, d)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertRestartService = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objset As SWbemObjectSet
    
    ' ��ѯ���ӵ����������Ƿ���ָ������
    Set objset = service.ExecQuery("select state from Win32_Service where name='" & d & "'")
    If objset.Count = 0 Then
        alertRestartService = "error=ָ��������" & d & "����!"
        Exit Function
    End If
    
    
    Dim objproc As Object
    ' ����������
    Set objproc = service.Get("Win32_Process")
    
    Dim str As String
    str = "ok"
    
    ' �ر�ָ������
    result = objproc.Create("net stop " & d, Null, Null, processid)
    
    ' ѭ������ָ�������Ƿ�ر���?
    Do While True
        Set objset = service.ExecQuery("select state from Win32_Service where name='" & d & "'")
        
        For Each tmp In objset
            If LCase(tmp.state) = "stopped" Then
                Exit Do
            End If
        Next
    Loop
    
    
    ' ��������ָ������
    result2 = objproc.Create("net start " & d, Null, Null, processid2)
    
    
    ' ������
    If Err.Number <> 0 Then
        alertRestartService = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        alertRestartService = str
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objset = Nothing
    Set x = Nothing
End Function



'======================================================================================================
' ���� : ����IIS
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
'
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertRestartIIS = ���������Ĵ�
'        ��ȡ��ֵʱ��alertRestartIIS = �մ�
'======================================================================================================
Public Function alertRestartIIS(a, b, c)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertRestartIIS = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objset As SWbemObjectSet
    
    ' ��ѯ���ӵ����������Ƿ���IIS����
    Set objset = service.ExecQuery("select state from Win32_Service where name='w3svc'")
    If objset.Count = 0 Then
        alertRestartIIS = "error=ָ��������WWW����!"
        Exit Function
    End If
    
    
    Dim objproc As Object
    ' ����������
    Set objproc = service.Get("Win32_Process")
    
    Dim str As String
    str = "ok"
    
    ' �ж�IIS��ǰ״̬,�����ǰ���Ѿ��ǹرյ���,��ֱ����������
    Set objset = service.ExecQuery("select state from Win32_Service where name='w3svc'")
    For Each tmp In objset
        If LCase(tmp.state) = "stopped" Then
            ' ��������IIS
            result2 = objproc.Create("net start w3svc", Null, Null, processid2)
            alertRestartIIS = str
            Exit Function
        End If
    Next
    
    
    ' �ر�IIS
    result = objproc.Create("net stop w3svc", Null, Null, processid)
    
    ' ѭ������IIS�Ƿ�ر���?
    Do While True
        Set objset = service.ExecQuery("select state from Win32_Service where name='w3svc'")
        
        For Each tmp In objset
            If LCase(tmp.state) = "stopped" Then
                Exit Do
            End If
        Next
    Loop
    
    
    ' ��������IIS
    result2 = objproc.Create("net start w3svc", Null, Null, processid2)
    
    
    ' ������
    If Err.Number <> 0 Then
        alertRestartIIS = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        alertRestartIIS = str
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objset = Nothing
    Set x = Nothing
End Function



'======================================================================================================
' ���� : ����Ϣ
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
'        targetMachine  Ŀ������
'        strMsg  ��Ϣ����
'
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertSendMessage = ���������Ĵ�
'        ��ȡ��ֵʱ��alertSendMessage = �մ�
'======================================================================================================
Public Function alertSendMessage(a, b, c, targetMachine, strMsg)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertSendMessage = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objset As Object
    Set objset = service.Get("Win32_Process")
    
    Dim str As String
    str = "net send " & targetMachine & " """ & strMsg & """"
    result = objset.Create(str, Null, Null, processid)
    
'    Dim x As SWbemObject, str As String
'    str = "ok"
'    If objset.Count > 0 Then
'        If Err.Number = 0 Then
'            For Each x In objset
'                x.shutdown
'            Next
'        End If
'    End If
    
    ' ������
    If Err.Number <> 0 Then
        alertSendMessage = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        str = "ok"
        alertSendMessage = str
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objset = Nothing
    Set x = Nothing
End Function



'======================================================================================================
' ���� : �ػ�
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
'
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertShutdown = ���������Ĵ�
'        ��ȡ��ֵʱ��alertShutdown = �մ�
'======================================================================================================
Public Function alertShutdown(a, b, c)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertShutdown = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objset As SWbemObjectSet
    Set objset = service.ExecQuery("select * from Win32_OperatingSystem where Primary=true")
    
    Dim x As SWbemObject, str As String
    str = "ok"
    If objset.Count > 0 Then
        If Err.Number = 0 Then
            For Each x In objset
                x.shutdown
            Next
        End If
    End If
    
    ' ������
    If Err.Number <> 0 Then
        alertShutdown = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        alertShutdown = str
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objset = Nothing
    Set x = Nothing
End Function



'======================================================================================================
' ���� : ��������
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
'
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertReboot = ���������Ĵ�
'        ��ȡ��ֵʱ��alertReboot = �մ�
'======================================================================================================
Public Function alertReboot(a, b, c)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertReboot = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objset As SWbemObjectSet
    Set objset = service.ExecQuery("select * from Win32_OperatingSystem where Primary=true")
    
    Dim x As SWbemObject, str As String
    str = "ok"
    If objset.Count > 0 Then
        If Err.Number = 0 Then
            For Each x In objset
                x.reboot
            Next
        End If
    End If
    
    ' ������
    If Err.Number <> 0 Then
        alertReboot = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        alertReboot = str
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objset = Nothing
    Set x = Nothing
End Function


'======================================================================================================
' ���� : ���������ļ�
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
'        e  ������·�����ļ���
'        f  �����ļ�·��������
'
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertPlaysound = "ok"
'        ��ȡ��ֵʱ��alertPlaysound = �մ�
'======================================================================================================
Public Function alertPlaysound(a, b, c, e, f)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertPlaysound = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objj As SWbemObject
    Set objj = service.Get("Win32_Process")
    'MsgBox Chr(34) & e & Chr(34) & " " & Chr(34) & f & Chr(34)
    result = objj.Create(Chr(34) & e & Chr(34) & " " & Chr(34) & f & Chr(34), Null, Null, processid)
    ' ������
    If Err.Number <> 0 Then
        alertPlaysound = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        alertPlaysound = "ok"
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objj = Nothing
End Function

'======================================================================================================
' ���� : ����Beep
'
' ���� : a  Ҫ���ӵķ�����������IP
'        b  �û���
'        c  ����
' ���� :
'        ����ʱ��error=Error Number : 123 Error Source : source Error Description : ����
'        ����ʱ��alertPlaysound = "ok"
'        ��ȡ��ֵʱ��alertPlaysound = �մ�
'======================================================================================================
Public Function alertPlayMsgBeep(a, b, c)
    On Error Resume Next
    
    
    Dim locator As New SWbemLocator
    Dim service As SWbemServices
    
    If Len(a) = 0 And Len(b) = 0 And Len(c) = 0 Then
        Set service = locator.ConnectServer
    Else
        Set service = locator.ConnectServer(a, "root\cimv2", b, c)
    End If
    
    ' ������
    If Err.Number <> 0 Then
        'getNetworkInterfaceNames = "Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description
        alertPlayMsgBeep = "error= service error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
        Exit Function
    End If
    
    Dim objj As SWbemObject
    Set objj = service.Get("Win32_Process")
    'MsgBox Chr(34) & e & Chr(34) & " " & Chr(34) & f & Chr(34)
     result = objj.Create("cmd.exe /C" & Chr(7) & Chr(7) & Chr(7) & Chr(7) & Chr(7) & Chr(7) & Chr(7), Null, Null, processid)
    ' ������
    If Err.Number <> 0 Then
        alertPlayMsgBeep = "error= get Date error! Error Number : " & Err.Number & vbCrLf & "Error Source : " & Err.Source & vbCrLf & "Error Description : " & Err.Description & "$"
    Else
        alertPlayMsgBeep = "ok"
    End If
    
    Set service = Nothing
    Set locator = Nothing
    Set objj = Nothing
End Function