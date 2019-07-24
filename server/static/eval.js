function MakeAjaxRequest(url, data){
    console.log("herer");
    req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        document.getElementById("eval-output").innerHTML = this.responseText;
      };
    req.open('POST', url, false);
    req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    req.send(data);
    console.log("hererer");
    console.log(url);
}

function SendQuery(url, query){
    console.log("here");
    if(event.key === 'Enter') {
        MakeAjaxRequest(url, query.value);        
    }
}
