
<?php

// Create connection
    $con=mysqli_connect('mysql.cs.iastate.edu','dbu309gkb2','vARV3zw@','db309gkb2');

// Check connection
    if (mysqli_connect_errno())
    {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    }

    $UserID=$_GET["UserID"];


    $TypeOperation=$_GET["TypeOperation"];
    $TypeObject=$_GET["TypeObject"];
    $ObjectID=$_GET["ObjectID"];
    
    
    $ShoppingListItemName=$_GET["ShoppingListItemName"];
    $ShoppingListItemDueDate=$_GET["ShoppingListItemDueDate"];
    $ShoppingListItemDone=$_GET["ShoppingListItemDone"];
    $ShoppingListItemCategory=$_GET["ShoppingListItemCategory"];
    $ShoppingListItemAmount=$_GET["ShoppingListItemAmount"];
    $ShoppingListItemAmountUnit=$_GET["ShoppingListItemAmountUnit"];

    $StandardTaskName=$_GET["StandardTaskName"];
    $StandardTaskDueDate=$_GET["StandardTaskDueDate"];
    $StandardTaskCheckMark=$_GET["StandardTaskCheckMark"];
    $StandardTaskReminderTime=$_GET["StandardTaskReminderTime"];
    $StandardTaskFrequence=$_GET["StandardTaskFrequency"];
    
    
    
    switch($TypeOperation)
    {
        case"NewUser":
            AddUser();
            break;
        case"Add":
            AddObject();
            break;
        case"Update":
            UpdateObject();
            break;
        case"Delete":
            DeleteObject();
            break;
        case"Fetch":
            FetchObject();
            break;
        default:
            echo "Error, No Such Operation";
            break;
    }
    
    function AddUser()
    {
        global $con,$UserID;
        $CommandToSQL="INSERT INTO User (UserID) VALUES('".$UserID."')";
        
        if($con->Query($CommandToSQL)==true)
        {
            
        }else{
            echo "Error: ".$CommandToSQL."<br>".$con->error."<br>";
        }
    }
    
    function FetchObject()
    {
        global $con,$TypeObject,$UserID;
        
        $CommandToSQL="SELECT * FROM db309gkb2.".$TypeObject." Where UserID = '".$UserID."'";

        $resultArray = array();
        $tempArray = array();
        
        if($result=mysqli_query($con,$CommandToSQL))
        {
            while($row=$result->fetch_assoc()){
                $tempArray=$row;
                array_push($resultArray,$tempArray);
            }
        }
        
        echo json_encode($resultArray);
        
    }
    function DeleteObject()
    {
        global $con,$ObjectID,$TypeObject;
        if($ObjectID!=null){
            $ComandToSQL="DELETE FROM ".$TypeObject." WHERE ID=".$ObjectID;
            if($con->query($ComandToSQL))
            {
                echo "Record Deleted Successfully, ID: ".$ObjectID;
            }else
            {
                echo "Error deleting record: ".$conn->error;
            }
        }else
        {
            echo "Input ObjectID Inorder to Delete";
        }

    }
    
    function UpdateObject()
    {
        global $con,$TypeObject;
        
        switch($TypeObject)
        {
            case"ShoppingListItem":
                UpdateShoppingListItem();
                break;
            default:
                echo"No Such TypeObject";
                break;
        }
        
    }
    
    function UpdateShoppingListItem()
    {
        global $con,$ObjectID,$ShoppingListItemName,$ShoppingListItemDueDate,$ShoppingListItemDone,$ShoppingListItemCategory,$ShoppingListItemAmount,$ShoppingListItemAmountUnit;
        
        if($ObjectID!=null){
            
            
            
            if($ShoppingListItemName!=null)
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET ItemName='".$ShoppingListItemName."' WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
                
            }
            if($ShoppingListItemDueDate=="NULL")
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET dueDate=NULL WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
            }else if($ShoppingListItemDueDate!=null)
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET dueDate='".$ShoppingListItemDueDate."' WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
                
            }
            
            if($ShoppingListItemDone!=null)
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET done='".$ShoppingListItemDone."' WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
                
            }
            
            
            if($ShoppingListItemCategory!=null)
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET category='".$ShoppingListItemCategory."' WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
                
            }
            
            
            if($ShoppingListItemAmount!=null)
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET amount='".$ShoppingListItemAmount."' WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
                
            }
            
            
            if($ShoppingListItemAmountUnit!=null)
            {
                
                $CommandToSQL="UPDATE ShoppingListItem SET amountUnit='".$ShoppingListItemAmountUnit."' WHERE ID=".$ObjectID;
                
                if($con->query($CommandToSQL)===true)
                {
                    echo "Record Updated Successfully<br>";
                }else{
                    echo "Error Updating Record: ".$con->error."<br>";
                }
                
            }
            
            $CommandToSQL="UPDATE ShoppingListItem SET Updatedates=CURRENT_TIMESTAMP WHERE ID=".$ObjectID;
            
            if($con->query($CommandToSQL)===true)
            {
                echo "Record Updated Successfully<br>, ID: ".$ObjectID;
            }else{
                echo "Error Updating Record: ".$con->error."<br>";
            }
            
            }else
            {
                echo "Input ObjectID Inorder to Update<br>";
            }
    }
    
    
    function AddObject()
    {
        global $con,$TypeObject;

        switch($TypeObject)
        {
            case"ShoppingListItem":
                AddShoppingListItem();
                break;
            case"StandardTask":
                AddStandardTask();
                break;
            default:
                echo"No Such TypeObject";
                break;
        }
    }
    
    function AddStandardTask()
    {
        global $StandardTaskName,$StandardTaskDueDate,$StandardTaskCheckMark,$StandardTaskReminderTime,$StandardTaskFrequence;
        global $con,$UserID;

        if ($StandardTaskName == null || $StandardTaskDueDate == null || $StandardTaskCheckMark == null|| $StandardTaskReminderTime == null|| $StandardTaskFrequence == null){
            echo "Error, Failed Add, No Enough Parameter Input<br>";
        }else{
            
            
            if($StandardTaskDueDate=="NULL")
            {
                $DueDate=",NULL";
            }else{
                $DueDate=",'".$StandardTaskDueDate."'";
                
            }
            
            if($StandardTaskReminderTime == "NULL")
            {
                $ReminderTime=",NULL";
            }else{
                $ReminderTime=",'".$StandardTaskReminderTime."'";
            }
            
            if($StandardTaskFrequence == "NULL")
            {
                $TaskFrequence=",NULL";
                
            }else{
                $TaskFrequence=",'".$StandardTaskFrequence."'";
            }
            
            $CheckMark=",'".$StandardTaskCheckMark."'";
            
            $CommandToSQL="INSERT INTO StandardTask (UserID,TaskName,DueDate,CheckMark,ReminderTime,Frequency,Updatedates) VALUES('".$UserID."','".$StandardTaskName."'".$DueDate.$CheckMark.$ReminderTime.$TaskFrequence.",CURRENT_TIMESTAMP)";
            
        }
        
        if($con->Query($CommandToSQL)==true)
        {
            $ID=$con->insert_id;
            echo $ID;
        }else{
            echo "Error: ".$CommandToSQL."<br>".$con->error."<br>";
        }
        
        
    }
    
    function AddShoppingListItem()
    {
        global $con,$UserID,$ShoppingListItemName,$ShoppingListItemDueDate,$ShoppingListItemDone,$ShoppingListItemCategory,$ShoppingListItemAmount,$ShoppingListItemAmountUnit;
        
        if($UserID==null|| $ShoppingListItemName==null || $ShoppingListItemDone==null || $ShoppingListItemCategory==null||$ShoppingListItemAmount==null||$ShoppingListItemAmountUnit==null)
        {
            echo "Error, Failed Add, No Enough Parameter Input<br>";
            
            echo $UserID."<br>".$ShoppingListItemName."<br>".$ShoppingListItemDone."<br>".$ShoppingListItemCategory."<br>".$ShoppingListItemAmount."<br>".$ShoppingListItemAmountUnit."<br>";
            
            
            if($UserID==null)
            {
                echo "UserID";
            }
            if($ShoppingListItemName==null)
            {
                echo "$ShoppingListItemName";
            }
            if($ShoppingListItemDone==null)
            {
                echo "$ShoppingListItemDone";
            }
            if($ShoppingListItemCategory==null)
            {
                echo "$ShoppingListItemCategory";
            }
            if($ShoppingListItemAmount==null)
            {
                echo "$ShoppingListItemAmount";
            }
            if($ShoppingListItemAmountUnit==null)
            {
                echo "$ShoppingListItemAmountUnit";
            }
            
            
        }else{
            if($ShoppingListItemDueDate!=null && $ShoppingListItemDueDate!="NULL")
            {
                $CommandToSQL="INSERT INTO ShoppingListItem (UserID,ItemName,dueDate,done,category,amount,amountUnit,updatedates) VALUES('".$UserID."','".$ShoppingListItemName."','".$ShoppingListItemDueDate."','".$ShoppingListItemDone."','".$ShoppingListItemCategory."','".$ShoppingListItemAmount."','".$ShoppingListItemAmountUnit."',CURRENT_TIMESTAMP)";
                
            }else{
                $CommandToSQL="INSERT INTO ShoppingListItem (UserID,ItemName,dueDate,done,category,amount,amountUnit,updatedates) VALUES('".$UserID."','".$ShoppingListItemName."',NULL,'".$ShoppingListItemDone."','".$ShoppingListItemCategory."','".$ShoppingListItemAmount."','".$ShoppingListItemAmountUnit."',CURRENT_TIMESTAMP)";
            }
            
            
            if($con->Query($CommandToSQL)==true)
            {
                $ID=$con->insert_id;
                echo $ID;
            }else{
                echo "Error: ".$CommandToSQL."<br>".$con->error."<br>";
            }
        }
    }
    
    
    
// Close connections
mysqli_close($con);
?>

