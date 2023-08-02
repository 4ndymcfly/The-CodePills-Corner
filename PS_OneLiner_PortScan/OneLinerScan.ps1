1..1024 | % {echo ((New-Object Net.Sockets.TcpClient).Connect("192.168.1.1", $_)) "TCP port $_ is open"} 2>$null
