/*************************************
 * AXL Stuff to get all devices in DB
 *************************************/

// Create SOAP Connection
$soap_axl = new SoapClient(__DIR__ . '/../schema/8.0/AXLAPI.wsdl',
array(
	"trace"=>true,
	"exceptions"=>true,
	"location"=>"https://".$server.":8443/axl",
	"login"=>$AXLUser,
	"password"=>$AXLPwd,
));

// Get 'phone' devices via SQL Query
// And split them up in chunks of 200 (max return for risport)
$query="select name,description,tkmodel from device where tkclass = '1'";
$response = $soap_axl->ExecuteSQLQuery(array("sql"=>"$query"));
// TODO need to have a look, if no devices, 'row' won't exist in the response
$devices = $response->return->row;
$devices_chunks = array_chunk($devices,200);

$total_DB = count($devices);
echo "Total Devices found in DB: " . count($devices) . "\n";
echo "You will need " . count($devices_chunks) . " dots\n";

/*******************************************
 *  RisPort stuff to check on device status
 *******************************************/

// Create SOAP Connection
$soap_ris = new SoapClient("../schema/RisPort.wsdl",
	array(
		"trace"=>true,
		"exceptions"=>true,
		"location"=>"https://".$server.":8443/realtimeservice/services/RisPort",
		"login"=>$AXLUser,
		"password"=>$AXLPwd,
	));

$itt = 0;
foreach ($devices_chunks as $chunk){
	echo '.';

	//Prepare RisPort request
	$array["SelectBy"] = "Name";
	$array["Status"] = "Registered";
	//$array["Class"] = "Phone";
	//$array["MaxReturnedDevices"] = "1000";
	$i = 1;
	foreach($chunk as $device){
		$array["SelectItems"]["SelectItem[$i]"]["Item"] = $device->name;
		$i++;
	}
	
	// Run RisPost Query + wait a bit as max requests is 15 per min.
	$response = $soap_ris->SelectCmDevice("",$array);
	sleep(5);