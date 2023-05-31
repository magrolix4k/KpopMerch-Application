<?php
    $db = mysqli_connect('localhost','u528477660_kpopmerch','zywA4nKs','u528477660_kpopmerch');
    
    if(!$db){
        die("Database connection failed");
    }

    $email = $_POST['email'];
    $password = $_POST['password'];

    $sql = "SELECT * FROM user_data WHERE email = '".$email."' AND password = '".$password."'";

    $result = mysqli_query($db,$sql);
    $count = mysqli_num_rows($result);

    if($count == 1){
        echo json_encode("Error");
        echo('dsadsa');
    }else{
        $insert = "INSERT INTO user_data(email,password)VALUES('".$email."','".$password."')";
        $query = mysqli_query($db,$insert);
    }if ($query){
        echo json_encode("Success");
    }
?>