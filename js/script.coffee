# Author: everpointer
# error happened:
# XmlHttpRequest error: Origin null is not allowed by Access-Control-Allow-Origin
jQuery.support.cors = true;
host = "http://localhost"
port = "3000"
base_url = host + ":" + port

fetch_comments = (operator_id, fetch_id, platform, page) ->
    init_comment_box()
    fetch_url = base_url + "/comments?operator_id="+operator_id+"&fetch_id=" + fetch_id + "&platform="+platform + "&page="+page

    # setting hidden value
    $("#current_page").val page
    $("#current_operator_id").val operator_id
    $("#current_fetch_id").val fetch_id
    $("#current_platform").val platform
    $.get fetch_url, (data, textStatus) ->
        # data = JSON.parse data
        $(".bar").css "width", "50%"
        handle_comment_result fetch_id, platform, data
        $(".bar").css "width", "80%"
        # setting hidden value
        $("#current_page_size").val data.data.length
        $("#page_size").val data.info.page_size
        $(".bar").css "width", "100%"
        $(".progress").css "display", "none"
        # dis and enable page navigation
        if $("#current_page").val() <= 1
            $(".previous").addClass("disabled")
        else
            $(".previous").removeClass("disabled")
        if $("#current_page_size").val() < $("#page_size").val()
            $(".next").addClass("disabled")
        else
            $(".next").removeClass("disabled")
    , 'jsonp'

init_comment_box = ->
    $(".progress").css "display", "block"
    $(".bar").css "width", "10%"
    $(".comment_box").html ""
handle_comment_result = (fetch_id, platform, data) ->
    switch platform
        when "taobao" then display_tb_comment(fetch_id, data)
        when "dianping" then display_dp_comment(fetch_id, data)
        else alert("unknown platform:" + platform)

# 显示淘宝的评论列表
display_tb_comment = (fetch_id, data) ->
    display_content = ""
    for comment_entry in data.data
        display_content += gen_tb_comment_entry(fetch_id, comment_entry);
    $(".comment_box").html(display_content);
gen_tb_comment_entry = (fetch_id, comment_entry) ->
    # comment_result =
    #     '<div class="comment-content">
    #         <h3>
    #             <a href="#" target="_blank">'+comment_entry['nick']+'</a>
    #             <span class="time">
    #                 <span class="time">'+comment_entry['date']+'</span>
    #             </span>
    #         </h3>
    #         <div class="comment-rst">
    #             <div class="comment-entry">
    #                 <blockquote>'+comment_entry['content']+'</blockquote>
    #             </div>
    #         </div>
    #     </div>';
    comment_result =
        '<hr>
       <div class="comment-content row">
           <div class="span2">
               <p><a href="'+comment_entry['userLink']+'" target="_blank">'+comment_entry['nick']+'</a></p>
               <p><img src="'+comment_entry['userCreditImg']+'"></p>
               <p>Vip：'+comment_entry['userVipLevel']+'</p>
           </div>
           <div class="comment-rst span8">
               <blockquote>'+comment_entry['content']+'</blockquote>
               <div class="comment-date">'+comment_entry['date']+'</div>
           </div>
        </div>';
    return comment_result;
# 显示淘宝的评论列表
display_dp_comment = (fetch_id, data) ->
    display_content = ""
    for comment_entry in data.data
        display_content += gen_dp_comment_entry(fetch_id, comment_entry);
    $(".comment_box").html(display_content);
gen_dp_comment_entry = (fetch_id, comment_entry) ->
    comment_result =
        '<hr>
        <div class="comment-content row">
            <div class="span2">
                <p><a href="http://www.dianping.com/member/'+comment_entry['user_id']+'" target="_blank"><img src="'+comment_entry['avatar']+'"></a></p>
                <p>
                    <a href="http://www.dianping.com/member/'+
                    comment_entry['user_id']+'" target="_blank">'+comment_entry['user_name']+'</a>
                </p>
            </div>
            <div class="comment-rst span10">
                <div>
                    <span>评分：'+comment_entry['comment_star']+'颗星</span>
                    <span>口味：'+comment_entry['flavour']+'</span>
                    <span>环境：'+comment_entry['environment']+'</span>
                    <span>服务：'+comment_entry['service']+'</span>';
    if comment_entry['average'] && typeof comment_entry['average'] isnt undefined
        comment_result += '<span>人均：'+comment_entry['average']+'</span>'
    comment_result += '
                </div>
                <div class="comment-entry">
                    <span class="cateComment">'+(comment_entry['comment_type'] || "")+'</span>
                    <blockquote>'+comment_entry['comment_content']+'</blockquote>
                    <div class="more">
                        <a href="http://www.dianping.com/review/'+fetch_id+'" target="_blank">全文</a>
                    </div>
                    <div class="time">'+comment_entry['comment_time']+'</div>
                </div>
            </div>
        </div>';
    return comment_result;
# 显示点评的评论列表
# todo: implement it
# if $("#current_platform").val() is "" && $("#current_fetch_id").val() is ""
#     fetch_comments('18319176950', 'taobao', 1);
    # fetch_comments('2131474', 'dianping', 1);
# set pager event handler
$(".previous").click (e)->
    # e.preventDefault()
    current_page = $("#current_page").val()
    current_page_size = $("#current_page_size").val()
    page_size = $("#page_size").val()
    current_operator_id = $("#current_operator_id").val()
    current_fetch_id = $("#current_fetch_id").val()
    current_platform = $("#current_platform").val()

    return false if current_page <= 1
    fetch_comments current_operator_id, current_fetch_id, current_platform, --current_page

$(".next").click (e)->
    # e.preventDefault()
    current_page = $("#current_page").val()
    current_page_size = $("#current_page_size").val()
    page_size = $("#page_size").val()
    current_operator_id = $("#current_operator_id").val()
    current_fetch_id = $("#current_fetch_id").val()
    current_platform = $("#current_platform").val()

    return false if current_page_size < page_size
    fetch_comments current_operator_id, current_fetch_id, current_platform, ++current_page

# executed code when page done loading
# todo: typehead not working
$(".typeahead").typeahead(
    source : (typeahead, query) ->
        host = "http://localhost"
        port = "3000"
        base_url = host + ":" + port
        # url = base_url + "/products?platform=" + "taobao&title="+query
        platform = $("#current_platform").val()
        url = base_url + "/products?platform=" + platform + "&title="+query
        $.ajax(
            url: url
            method: 'GET'
            dataType: "jsonp"
            success: (data) ->
                typeahead.process(data)
        )
    ,
    property: "title"
    items: 15
    onselect: (obj) ->
        # $("#platform").text("淘宝");
        # $("#product").text $("#search_product").val()
        # $(".progress").css("display" , 'block');
        # fetch_comments obj.operator_id, obj.fetch_id, "taobao", 1
        # $("#platform").text("点评");
        # $("#product").text $("#search_product").val()
        $(".progress").css("display" , 'block');
        platform = $("#current_platform").val()
        show_shop_info platform, obj
        fetch_comments obj.operator_id, obj.fetch_id, platform, 1
    timeout: if $("#current_platform").val() is "dianping" then 800 else 400
)
# 根据获取到的内容，显示店铺或商品的信息
show_shop_info = (platform, obj) ->
    shop_info = ""
    shop_url = ""
    if platform is "dianping"
        shop_url = "http://www.dianping.com/shop/"+obj.fetch_id
        shop_info = "<dl class='detail'>
                <dt>店铺信息</dt>
                <dd class='shopname'><a href='"+shop_url+"'>"+$("#search_product").val()+"</a></dd>
                <dd class='address'><strong>地址：</strong>"+obj.address+"</dd>
                <dd class='rate'>评分："+obj.rate+"颗星</dd>
                <dd class='average'>人均：￥"+obj.average+"</dd></dl>"
    else if platform is "taobao"
        shop_info = "<dl class='detail'>
                <dt>产品信息</dt>
                <dd class='shopname'><a href='"+obj.href+"'>"+$("#search_product").val()+"</a></dd>
                <dd class='sales_amount'>销售："+obj.sales_amount+"件</dd>
                <dd class='rate'>评分："+obj.rate+"</dd>
            </dl>"
    $("#shop_info_box").html shop_info

# bind platform dropdown events in bootstrap dropdown's format
$("#platform_menu .dropdown-menu li").click ->
    $("#search_product").removeAttr("disabled")
    platform_anchor = $(this).children("a")
    platform_text = platform_anchor.text()
    platform = platform_anchor.attr('value')

    $("#platform_menu a .dropdown_select").text platform_text
    $("#current_platform").val platform

    # page clear
    $("#search_product").val ""
    $("#shop_info_box").html ""
    $(".comment_box").html ""
    # $("#platform").text platform_text





