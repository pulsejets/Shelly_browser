#!/bin/bash
#avahi-browse --all -r -t -p |grep -i shelly >shelly_scan
 #cat shelly_scan |grep "Web Site" |grep "^[^+]" |cut -d ";" -f4,8,10- > washed_shelly
 avahi-browse  _http._tcp -r -t -p |grep -i shelly |grep "^[^+]" |cut -d ";" -f4,8,10- |cut -d" " -f4|sed 's/"//g'| cut -d"=" -f2  > washed_shelly
 #cat shelly_scan |grep "_shelly._tcp" |grep "^[^+]" |cut -d ";" -f8- > washed_shelly_2gen
 avahi-browse  _shelly._tcp -r -t -p |grep -i shelly |grep "^[^+]" |cut -d ";" -f8- >washed_shelly_2gen
echo `date` > /var/www/html/index.html

 cat <<EOT >> /var/www/html/index.html 
<!DOCTYPE html>
<html>
<head>
<title>Shelly Scanner</title>
<style>
table {
  border-spacing: 0;
  width: 100%;
  border: 1px solid #ddd;
}

th, td {
  text-align: left;
  padding: 16px;
}

tr:nth-child(even) {
  background-color: #f2f2f2
}
</style>
</head>
<body>


<table id="myTable"><tr>

<th onclick="sortTable(0)">no</th>
<th onclick="sortTable(1)">Hostname</th>
<th onclick="sortTable(2)">ip</th>
<th onclick="sortTable(3)">type</th>
<th onclick="sortTable(4)">Devicename</th>

<th onclick="sortTable(5)">cloud</th>
<th onclick="sortTable(6)">mqtt</th>
<th onclick="sortTable(7)">mqtt id</th>

<th onclick="sortTable(8)">power state</th>

</tr>
EOT
f=1
while read p; do
echo "<tr>" >>/var/www/html/index.html
	device=$(echo $p |cut -d ";" -f1)
	ip=$(echo $p |cut -d ";" -f2)
        type=$(echo $p |cut -d" " -f4|sed 's/"//g'| cut -d"=" -f2)
if [[ $type = "2" ]];then 

	type=$( cat washed_shelly_2gen |grep "$ip;" |cut -d ";" -f3 |sed 's/"//g' |cut -d" " -f3|cut -d"=" -f2)
        name=$(curl -s http://$ip/rpc/Shelly.GetDeviceInfo | jq -r ".name")
	mqtt_id=$(curl -s http:///rpc/Shelly.Getconfig | jq -r ".mqtt.topic_prefix")
	mqtt_enabled=$(curl -s http://$ip/rpc/Shelly.Getconfig | jq -r ".mqtt.enable")
else
	g=$(curl -s http://$ip/settings | jq -r ".name,.cloud.enabled,.mqtt.enable,.mqtt.id,.relays[0].ison" | sed -z 's/\n/;/g')
##	name=$(curl -s http://$ip/settings | jq -r ".name")
       name=$(echo $g |cut -d";" -f1)
       
       cloud=$(echo $g |cut -d";" -f2)
       
       mqtt_enabled=$(echo $g |cut -d";" -f3)

       mqtt_id=$(echo $g |cut -d";" -f4)

       ison=$(echo $g |cut -d";" -f5)
fi 
echo "<td>$f</td><td>$device</td><td><a href='http://$ip' target='_blank'>$ip</a></td><td>$type</td><td>$name</td><td>$cloud</td><td>$mqtt_enabled</td><td>$mqtt_id</td><td>$ison</td></tr>" >>/var/www/html/index.html
((f=f+1))
  done <washed_shelly

echo "</table>" >> /var/www/html/index.html
cat <<EOT >> /var/www/html/index.html 
<script>
function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("myTable");
  switching = true;
  //Set the sorting direction to ascending:
  dir = "asc"; 
  /*Make a loop that will continue until
  no switching has been done:*/
  while (switching) {
    //start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /*Loop through all table rows (except the
    first, which contains table headers):*/
    for (i = 1; i < (rows.length - 1); i++) {
      //start by saying there should be no switching:
      shouldSwitch = false;
      /*Get the two elements you want to compare,
      one from current row and one from the next:*/
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      /*check if the two rows should switch place,
      based on the direction, asc or desc:*/
      if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          //if so, mark as a switch and break the loop:
          shouldSwitch= true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          //if so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /*If a switch has been marked, make the switch
      and mark that a switch has been done:*/
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      //Each time a switch is done, increase this count by 1:
      switchcount ++;      
    } else {
      /*If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again.*/
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}
</script>
</body>
</html>
EOT

#rm -f shelly_* washed_*
