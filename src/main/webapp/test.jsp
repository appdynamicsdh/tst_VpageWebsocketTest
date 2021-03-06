<%@ page import="com.appdynamics.apm.appagent.api.AgentDelegate" %>
<html>
<head>
    <title>TEST Page</title>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script >
        var connection = new WebSocket('ws://localhost:8881/WebsocketTestcase/wes');

        function logServer(e){
            console.log('Server: ' + e.data);
        }
        // Log messages from the server
            connection.onmessage = logServer;

        function guid() {
            function s4() {
                return Math.floor((1 + Math.random()) * 0x10000)
                    .toString(16)
                    .substring(1);
            }
            return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                s4() + '-' + s4() + s4() + s4();
        }

        function executeCallback2 () {
            executeCallback("#txt");

            window.setTimeout(executeCallback2,5000);
        }
        function executeCallback (element) {


            // Start a VPage to wrap the performance Values of this WS Call
            var vPageView = new ADRUM.events.VPageView({
                url: 'testpage3',
            });


            // Start the Timing
            vPageView.start();
            vPageView.markViewChangeStart();

            // Command to be send via WS
            $(element).html("")
            var uuid = guid();
            var obj = '{'
                +'"cmd" : "Echo",'
                +'"payload"  : "world",'
                +'"cmdId" : "'+uuid+'"'
                +'}';
            $(element).append("<p><b>Request:</b>"+obj+"</p>");



            vPageView.markViewChangeEnd();

            // Registring the return listener, The return listener will also retrieve the Correlation informaton
            var oldChain = connection.onmessage;
            connection.onmessage = function (resp) {
                var cmd = JSON.parse(resp.data);
                $(element).append("<p><b>Receiving: </b>" + cmd.cmdId + " <b>on UUID : </b>"+uuid+"  </p>");
                if (cmd.cmd === "reply" && cmd.cmdId === uuid) {
                    $(element).append("<p><b>Response:</b>" + cmd.payload + "</p>");

                    // Mark view Loaded to seperate network Time from Client Processing
                    vPageView.markViewDOMLoaded();


                    console.log(cmd.adrumData)

                    // This is important for correlation
                    // It will store the correlation Information which has been retrieved from the Server
                    // and make sure the Frontend Timing / VPage can be correlated to the Backend Processing
                    // DISCLAIMER: This method doesn't exist in the current Product, it'S part of the Enhancement
                    // Request we raised for Greentube
                    vPageView.adrumData (cmd.adrumData);


                    connection.onmessage = oldChain


                    // Wait for communication to end
                    // and End the VPage Timing
                    vPageView.markXhrRequestsCompleted();
                    vPageView.end();

                    // Queue the EUM Event for sending. It now contains all data to monitor the timing of this WS
                    // use case AND to correlate it to the Backend BT
                    ADRUM.report(vPageView);

                } else oldChain(resp);
                connection.onmessage = oldChain

            };

            // Finally: send the command. It'S best practice to register the listener BEFORE sending the command
            connection.send(obj)


        }
    </script>

    <script>
        $(document).ready(function(){
            $("#btn").click(function(){
                executeCallback("#txt");
            });
            $("#btn2").click(function(){
                executeCallback2();
            });
        });
    </script>


    <script language="JavaScript1.5" >
    function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function demo() {
  console.log('Taking a break...');
  await sleep(2000);
  console.log('Two second later');
}
demo();
</script>

    <script language="JavaScript1.5">

    async function clickSimple() {
        console.log('Simple Beacon..');
        var vPageView = new ADRUM.events.VPageView({
            url: 'mySimpleVPage',
        });

        vPageView.start();

        await sleep(50);
        vPageView.markViewChangeStart();

        await sleep(140);
        vPageView.markViewChangeEnd();

ADRUM.command ("addUserData", "customer_id", "6767");

        await sleep(50);
        vPageView.markViewDOMLoaded();


        await sleep(150);


        vPageView.markXhrRequestsCompleted();

        await sleep(250);

        vPageView.end();

        ADRUM.report(vPageView);

         console.log('... done!');

    }

    function addXHR(name) {
    var ajaxT = new ADRUM.events.Ajax();

// set url
ajaxT.url(name);

// mark timings
ajaxT.markSendTime(100);
ajaxT.markFirstByteTime(200);
ajaxT.markRespAvailTime(300);
ajaxT.markRespProcTime(400);
ADRUM.report(ajaxT);
    }

    async function clickComplex() {
        console.log('Complex Beacon..');

        var vPageView = new ADRUM.events.VPageView({
            url: 'myComplexVPage',
        });

        vPageView.start();

        await sleep(50);
        vPageView.markViewChangeStart();

        await sleep(140);
        vPageView.markViewChangeEnd();

ADRUM.command ("addUserData", "customer_ghg", "6767");

        await sleep(50);
        vPageView.markViewDOMLoaded();


        await sleep(150);

        // add some XHR Pages
        addXHR("http://ajax.com/test1");
        addXHR("http://ajax.com/test2");
        addXHR("http://ajax.com/test3");
        addXHR("http://ajax.com/test1");

        await sleep(150);

        vPageView.markXhrRequestsCompleted();

        await sleep(250);

        vPageView.end();

        ADRUM.report(vPageView);

         console.log('... done!');
    }


</script>

</head>
<script charset='UTF-8'>
    window['adrum-start-time'] = new Date().getTime();
    (function(config){
        config.appKey = 'AD-AAB-AAF-SUG';
        config.adrumExtUrlHttp = 'http://localhost:8881/WebsocketTestcase/addev';
        config.adrumExtUrlHttps = 'https://localhost:8881/WebsocketTestcase/addev';
//        config.adrumExtUrlHttp = 'http://localhost:8881/WebsocketTestcase/ad';
//        config.adrumExtUrlHttps = 'https://localhost:8881/WebsocketTestcase/ad';
        config.beaconUrlHttp = 'http://col.eum-appdynamics.com';
        config.beaconUrlHttps = 'https://col.eum-appdynamics.com';
        config.xd = {enable : false};
    })(window['adrum-config'] || (window['adrum-config'] = {}));
    if ('https:' === document.location.protocol) {
        document.write(unescape('%3Cscript')
            + " src='https://localhost:8881/WebsocketTestcase/addev/adrum/adrum.js' "
//            + " src='https://localhost:8881/SimpleWebAppTest/ad/adrum/adrum.js' "
            + " type='text/javascript' charset='UTF-8'"
            + unescape('%3E%3C/script%3E'));
    } else {
        document.write(unescape('%3Cscript')
            + " src='http://localhost:8881/WebsocketTestcase/addev/adrum/adrum.js' "
//            + " src='http://localhost:8881/SimpleWebAppTest/ad/adrum/adrum.js' "
            + " type='text/javascript' charset='UTF-8'"
            + unescape('%3E%3C/script%3E'));
    }
</script>

<Body>
    <h1> My Testpage </h1>

    <hr/>
    <pre>    <%=AgentDelegate.getTransactionDemarcator().getUniqueIdentifierForTransaction()%>
      <%String meta = AgentDelegate.getEndUserMonitoringDelegate()
              .getFooter()
              .replaceAll("<script type='text/javascript'>","")
              .replaceAll("</script>","")
              .replaceAll("//<!\\[CDATA\\[","")
              .replaceAll("//]]>","");
//       .split("\\[")[1];
  //      meta = meta.split("\\]")[0];
    //    meta = "["+meta+"]";
      %>

        <%=meta%>

    </pre>
    <hr/>


    <button onclick="clickSimple()">Press for Simple Test</button>
    <hr/>
    <button onclick="clickComplex()">Press for complex Test</button>
    <hr/>

    <h1>Websocket Test</h1>

    <b>Value :</b> <p id="txt"></p>

    <button id="btn">CallBack</button><button id="btn2">CallBack Repeat</button>
<hr/>
</Body>
</html>