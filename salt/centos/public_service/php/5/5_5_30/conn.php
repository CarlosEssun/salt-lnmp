<?php
     $link = mysql_connect('192.168.1.115:3307','david','lovelove');
     if ($link)
       echo "Success...";
     else
       echo "Failure...";
     mysql_close();
?> 
