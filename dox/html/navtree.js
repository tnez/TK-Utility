var NAVTREE =
[
  [ "TK-Utility", "index.html", [
    [ "Class List", "annotated.html", [
      [ "GTMTestCase", "interface_g_t_m_test_case.html", null ],
      [ "<TKComponentBundleDelegate>", "protocol_t_k_component_bundle_delegate-p.html", null ],
      [ "<TKComponentBundleLoading>", "protocol_t_k_component_bundle_loading-p.html", null ],
      [ "TKComponentCocoaApp", "interface_t_k_component_cocoa_app.html", null ],
      [ "TKComponentController", "interface_t_k_component_controller.html", null ],
      [ "TKDelimitedFileParser", "interface_t_k_delimited_file_parser.html", null ],
      [ "TKDelimitedFileParserTest", "interface_t_k_delimited_file_parser_test.html", null ],
      [ "TKLibrary", "interface_t_k_library.html", null ],
      [ "TKLogging", "interface_t_k_logging.html", null ],
      [ "TKLogQueueItem", "interface_t_k_log_queue_item.html", null ],
      [ "TKNotificationQueueItem", "interface_t_k_notification_queue_item.html", null ],
      [ "TKPreferences", "interface_t_k_preferences.html", null ],
      [ "TKPreferencesDelegate", "interface_t_k_preferences_delegate.html", null ],
      [ "TKQuestion", "interface_t_k_question.html", null ],
      [ "TKQuestionSet", "interface_t_k_question_set.html", null ],
      [ "TKSubject", "interface_t_k_subject.html", null ],
      [ "TKTime", "struct_t_k_time.html", null ],
      [ "TKTimer", "interface_t_k_timer.html", null ],
      [ "TKTimerTest", "interface_t_k_timer_test.html", null ]
    ] ],
    [ "Class Index", "classes.html", null ],
    [ "Class Hierarchy", "hierarchy.html", [
      [ "GTMTestCase", "interface_g_t_m_test_case.html", [
        [ "TKDelimitedFileParserTest", "interface_t_k_delimited_file_parser_test.html", null ]
      ] ],
      [ "<TKComponentBundleDelegate>", "protocol_t_k_component_bundle_delegate-p.html", [
        [ "TKComponentController", "interface_t_k_component_controller.html", null ]
      ] ],
      [ "<TKComponentBundleLoading>", "protocol_t_k_component_bundle_loading-p.html", null ],
      [ "TKComponentCocoaApp", "interface_t_k_component_cocoa_app.html", null ],
      [ "TKDelimitedFileParser", "interface_t_k_delimited_file_parser.html", null ],
      [ "TKLibrary", "interface_t_k_library.html", null ],
      [ "TKLogging", "interface_t_k_logging.html", null ],
      [ "TKLogQueueItem", "interface_t_k_log_queue_item.html", null ],
      [ "TKNotificationQueueItem", "interface_t_k_notification_queue_item.html", null ],
      [ "TKPreferences", "interface_t_k_preferences.html", null ],
      [ "TKPreferencesDelegate", "interface_t_k_preferences_delegate.html", null ],
      [ "TKQuestion", "interface_t_k_question.html", null ],
      [ "TKQuestionSet", "interface_t_k_question_set.html", null ],
      [ "TKSubject", "interface_t_k_subject.html", null ],
      [ "TKTime", "struct_t_k_time.html", null ],
      [ "TKTimer", "interface_t_k_timer.html", null ],
      [ "TKTimerTest", "interface_t_k_timer_test.html", null ]
    ] ],
    [ "Class Members", "functions.html", null ],
    [ "File List", "files.html", [
      [ "GTMDefines.h", null, null ],
      [ "GTMSenTestCase.h", null, null ],
      [ "TKComponentBundleDelegate.h", null, null ],
      [ "TKComponentCocoaApp.h", null, null ],
      [ "TKComponentController.h", null, null ],
      [ "TKDelimitedFileParser.h", null, null ],
      [ "TKDelimitedFileParserTest.h", null, null ],
      [ "TKLibrary.h", null, null ],
      [ "TKLogging.h", null, null ],
      [ "TKLogQueueItem.h", null, null ],
      [ "TKNotificationQueueItem.h", null, null ],
      [ "TKPreferences.h", null, null ],
      [ "TKQuestion.h", null, null ],
      [ "TKQuestionSet.h", null, null ],
      [ "TKSubject.h", null, null ],
      [ "TKTime.h", null, null ],
      [ "TKTimer.h", null, null ],
      [ "TKTimerTest.h", null, null ],
      [ "TKUtility.h", null, null ]
    ] ]
  ] ]
];

function createIndent(o,domNode,node,level)
{
  if (node.parentNode && node.parentNode.parentNode)
  {
    createIndent(o,domNode,node.parentNode,level+1);
  }
  var imgNode = document.createElement("img");
  if (level==0 && node.childrenData)
  {
    node.plus_img = imgNode;
    node.expandToggle = document.createElement("a");
    node.expandToggle.href = "javascript:void(0)";
    node.expandToggle.onclick = function() 
    {
      if (node.expanded) 
      {
        $(node.getChildrenUL()).slideUp("fast");
        if (node.isLast)
        {
          node.plus_img.src = node.relpath+"ftv2plastnode.png";
        }
        else
        {
          node.plus_img.src = node.relpath+"ftv2pnode.png";
        }
        node.expanded = false;
      } 
      else 
      {
        expandNode(o, node, false);
      }
    }
    node.expandToggle.appendChild(imgNode);
    domNode.appendChild(node.expandToggle);
  }
  else
  {
    domNode.appendChild(imgNode);
  }
  if (level==0)
  {
    if (node.isLast)
    {
      if (node.childrenData)
      {
        imgNode.src = node.relpath+"ftv2plastnode.png";
      }
      else
      {
        imgNode.src = node.relpath+"ftv2lastnode.png";
        domNode.appendChild(imgNode);
      }
    }
    else
    {
      if (node.childrenData)
      {
        imgNode.src = node.relpath+"ftv2pnode.png";
      }
      else
      {
        imgNode.src = node.relpath+"ftv2node.png";
        domNode.appendChild(imgNode);
      }
    }
  }
  else
  {
    if (node.isLast)
    {
      imgNode.src = node.relpath+"ftv2blank.png";
    }
    else
    {
      imgNode.src = node.relpath+"ftv2vertline.png";
    }
  }
  imgNode.border = "0";
}

function newNode(o, po, text, link, childrenData, lastNode)
{
  var node = new Object();
  node.children = Array();
  node.childrenData = childrenData;
  node.depth = po.depth + 1;
  node.relpath = po.relpath;
  node.isLast = lastNode;

  node.li = document.createElement("li");
  po.getChildrenUL().appendChild(node.li);
  node.parentNode = po;

  node.itemDiv = document.createElement("div");
  node.itemDiv.className = "item";

  node.labelSpan = document.createElement("span");
  node.labelSpan.className = "label";

  createIndent(o,node.itemDiv,node,0);
  node.itemDiv.appendChild(node.labelSpan);
  node.li.appendChild(node.itemDiv);

  var a = document.createElement("a");
  node.labelSpan.appendChild(a);
  node.label = document.createTextNode(text);
  a.appendChild(node.label);
  if (link) 
  {
    a.href = node.relpath+link;
  } 
  else 
  {
    if (childrenData != null) 
    {
      a.className = "nolink";
      a.href = "javascript:void(0)";
      a.onclick = node.expandToggle.onclick;
      node.expanded = false;
    }
  }

  node.childrenUL = null;
  node.getChildrenUL = function() 
  {
    if (!node.childrenUL) 
    {
      node.childrenUL = document.createElement("ul");
      node.childrenUL.className = "children_ul";
      node.childrenUL.style.display = "none";
      node.li.appendChild(node.childrenUL);
    }
    return node.childrenUL;
  };

  return node;
}

function showRoot()
{
  var headerHeight = $("#top").height();
  var footerHeight = $("#nav-path").height();
  var windowHeight = $(window).height() - headerHeight - footerHeight;
  navtree.scrollTo('#selected',0,{offset:-windowHeight/2});
}

function expandNode(o, node, imm)
{
  if (node.childrenData && !node.expanded) 
  {
    if (!node.childrenVisited) 
    {
      getNode(o, node);
    }
    if (imm)
    {
      $(node.getChildrenUL()).show();
    } 
    else 
    {
      $(node.getChildrenUL()).slideDown("fast",showRoot);
    }
    if (node.isLast)
    {
      node.plus_img.src = node.relpath+"ftv2mlastnode.png";
    }
    else
    {
      node.plus_img.src = node.relpath+"ftv2mnode.png";
    }
    node.expanded = true;
  }
}

function getNode(o, po)
{
  po.childrenVisited = true;
  var l = po.childrenData.length-1;
  for (var i in po.childrenData) 
  {
    var nodeData = po.childrenData[i];
    po.children[i] = newNode(o, po, nodeData[0], nodeData[1], nodeData[2],
        i==l);
  }
}

function findNavTreePage(url, data)
{
  var nodes = data;
  var result = null;
  for (var i in nodes) 
  {
    var d = nodes[i];
    if (d[1] == url) 
    {
      return new Array(i);
    }
    else if (d[2] != null) // array of children
    {
      result = findNavTreePage(url, d[2]);
      if (result != null) 
      {
        return (new Array(i).concat(result));
      }
    }
  }
  return null;
}

function initNavTree(toroot,relpath)
{
  var o = new Object();
  o.toroot = toroot;
  o.node = new Object();
  o.node.li = document.getElementById("nav-tree-contents");
  o.node.childrenData = NAVTREE;
  o.node.children = new Array();
  o.node.childrenUL = document.createElement("ul");
  o.node.getChildrenUL = function() { return o.node.childrenUL; };
  o.node.li.appendChild(o.node.childrenUL);
  o.node.depth = 0;
  o.node.relpath = relpath;

  getNode(o, o.node);

  o.breadcrumbs = findNavTreePage(toroot, NAVTREE);
  if (o.breadcrumbs == null)
  {
    o.breadcrumbs = findNavTreePage("index.html",NAVTREE);
  }
  if (o.breadcrumbs != null && o.breadcrumbs.length>0)
  {
    var p = o.node;
    for (var i in o.breadcrumbs) 
    {
      var j = o.breadcrumbs[i];
      p = p.children[j];
      expandNode(o,p,true);
    }
    p.itemDiv.className = p.itemDiv.className + " selected";
    p.itemDiv.id = "selected";
    $(window).load(showRoot);
  }
}

