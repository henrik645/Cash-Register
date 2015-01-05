<?php
  if(isset($_GET["account1"], $_GET["account2"], $_GET["amount"], $_GET["pin"])) {
    $account1 = $_GET["account1"]; // $account1 is the account the money will be transferred FROM
    $account2 = $_GET["account2"]; // $account2 is the account the money will be transferred TO
    $amount = $_GET["amount"]; // $amount is the amount that is to be transferred
    $pin = $_GET["pin"]; // $pin is the pin of the first account (the account from which the money is taken)
  } else {
    echo "error";
    die();
  }
  $db = new SQLite3('money.db');
  $statement1 = $db->prepare('SELECT balance FROM accounts WHERE UUID=:account1');
  $statement1->bindValue(':account1', $account1);
  $statement2 = $db->prepare('SELECT balance FROM accounts WHERE UUID=:account2');
  $statement2->bindValue(':account2', $account2);
  $oldBalance1 = $statement1->execute();
  $oldBalance1 = $oldBalance1->fetchArray(SQLITE3_ASSOC);
  $oldBalance2 = $statement2->execute();
  $oldBalance2 = $oldBalance2->fetchArray(SQLITE3_ASSOC);
  
  $statement1 = $db->prepare('SELECT pin FROM accounts WHERE UUID=:account1');
  $statement1->bindValue(':account1', $account1);
  $cardPin = $statement1->execute();
  $cardPin = $cardPin->fetchArray(SQLITE3_ASSOC);
  
  if($amount > $oldBalance1) {
    echo "nomoney";
  } elseif($pin != $cardPin["pin"]) {
    echo "pin";
  } elseif($account1 != $account2) {
    $statement = $db->prepare('UPDATE accounts SET balance=:newAmount WHERE UUID=:account1');
    $statement->bindValue(':newAmount', $oldBalance1["balance"] - $amount);
    $statement->bindValue(':account1', $account1);
    $statement->execute();
    
    $statement = $db->prepare('UPDATE accounts SET balance=:newAmount WHERE UUID=:account2');
    $statement->bindValue(':newAmount', $oldBalance2["balance"] + $amount);
    $statement->bindValue('account2', $account2);
    $statement->execute();
    echo "confirm";
  } else {
    echo "confirm";
  }
  
  $db->close();
  
?>