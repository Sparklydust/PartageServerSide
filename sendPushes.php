<?php
  
  const AUTH_KEY_PATH = '/Users/roland/Library/Mobile Documents/com~apple~CloudDocs/Documents/Bundle Code/Apple/Push Notification Key/AuthKey_PAL67NQ5FM.p8';
  const AUTH_KEY_ID = 'PAL67NQ5FM';
  const TEAM_ID = 'P8UNJX8SHV';
  const BUNDLE_ID = 'com.Sparklydust.Partage';
  
  $payload = [
  'aps' => [
  'alert' => [
  'title' => 'This is the notification.',
  ],
  'sound'=> 'default',
  ],
  ];
  
  $db = new PDO('pgsql:host=localhost;dbname=Partage;user=Sparklydust;password=E87Lp6y3eMAGbkTBKt9PGwsAi');
  
  function tokensToReceiveNotification($debug) {
    $sql = 'SELECT DISTINCT token FROM tokens WHERE debug = :debug';
    $stmt = $GLOBALS['db']->prepare($sql);
    $stmt->execute(['debug' => $debug ? 't' : 'f']);
    return $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
  }
  
  function generateAuthenticationHeader() {
    $header = base64_encode(json_encode([
                                        'alg' => 'ES256',
                                        'kid' => AUTH_KEY_ID
                                        ]));
    
    $claims = base64_encode(json_encode([
                                        'iss' => TEAM_ID,
                                        'iat' => time()
                                        ]));
    
    $pkey = openssl_pkey_get_private('file://' . AUTH_KEY_PATH);
    openssl_sign("$header.$claims", $signature, $pkey, 'sha256');
    
    $signed = base64_encode($signature);
    
    return "$header.$claims.$signed";
  }
  
  function sendNotifications($debug) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($GLOBALS['payload']));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'apns-topic: ' . BUNDLE_ID,
                'authorization: bearer ' . generateAuthenticationHeader(),
                ]);
    
    $removeToken = $GLOBALS['db']->prepare('DELETE FROM apns WHERE token = ?');
    $server = $debug ? 'api.development' : 'api';
    $tokens = tokensToReceiveNotification($debug);
    
    foreach ($tokens as $token) {
      $url = "https://$server.push.apple.com/3/device/$token";
      curl_setopt($ch, CURLOPT_URL, "{$url}");
      
      $response = curl_exec($ch);
      if ($response === false) {
        echo("curl_exec failed: " . curl_error($ch));
        continue;
      }
      
      $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
      if ($code === 400 || $code === 410) {
        $json = @json_decode($response);
        if ($json->reason === 'BadDeviceToken') {
          $removeToken->execute([$token]);
        }
      }
    }
    curl_close($ch);
  }
  
  sendNotifications(true); // Development (Sandbox)
  //sendNotifications(false), // Production
  
  ?>
