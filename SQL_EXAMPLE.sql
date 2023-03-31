-- Goal: 
-- Using the dataset to analyze current online website performance and using the data available to access upcoming opportunities

-- Context: 
-- Step1: Website performance improvement over 8 month
-- Step2: Identify customers are coming from which utm_source
-- Step3: Pull monthly trends for "gsearch" session and "gsearch" orders to showcase the growth of "gsearch"
-- Step4: Dive into “gsearch” more to understand  --- utm_campaign only have to, so split it 
-- Step5: See a monthly trend for 'Gsearch', but spilling out nonbrand vs brand separately to identify whether the company has always to rely on paid-traffic
-- Step6: Dive into more gsearch & nonbrand to see which device type has more orders
-- Step7: Under the situation when “gsearch” and “nonbrand, conducting A/B testing about “landing page
-- Step7-1: Identify where the test starts
-- Step7-2: Under the situation when “gsearch” and “nonbrand , identifying the first page id that customers visit in each session after the test starts
-- Step7-3: Identify the first page name (home vs lander1) that customers visit in each session after the test starts
-- Step7-4: Identify the total orders number from home page and land-1 page separately  
-- Step7-5: Calculate different landing page has different order conversion rate
-- Step7-6: Build conversion funnel to understand the effectiveness of two different landing pages under “gsearch ”and “nonbrand”
-- Step8: Identify which part of customer journey toward to purchasing that customers made for each customer

-- Step1: Website performance improvement over 8 month

select
	YEAR(website_sessions.created_at) AS YEAR,
    MONTH(website_sessions.created_at) AS MONTH,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
	COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS conver_rate
from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27'
	  AND MONTH(website_sessions.created_at) <9;



-- Step2: Identify customers are coming from which utm_source
select website_sessions.utm_source AS utm_source, COUNT(website_sessions.website_session_id) AS total_sessions
from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
group by 1;



-- Step3: Pull monthly trends for "gsearch" session and "gsearch" orders to showcase the growth of "gsearch".
--  Step4: Dive into “gsearch” more to understand  --- utm_campaign only have to, so split it 
select distinct utm_campaign
from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch';



-- Step5: See a monthly trend for 'Gsearch', but spilling out nonbrand vs brand separately to identify whether the company has always to rely on paid-traffic

select
	 YEAR(website_sessions.created_at)As Year,
	 MONTH(website_sessions.created_at)As Month,
     COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
     COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
     COUNT(CASE WHEN website_sessions.utm_campaign = 'brand'THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
     COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
     COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END)  AS conver_rate_nonbrand,
     COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) /COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END)  AS conver_rate_brand
from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
group by 1,2;



-- Step6: Dive into more gsearch & nonbrand to see which device type has more orders
select
	YEAR(website_sessions.created_at) AS YEAR,
    MONTH(website_sessions.created_at) AS MONTH,
    COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS moblie_sessions,
    COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS moblie_orders,
    COUNT(CASE WHEN website_sessions.device_type = 'desktop'THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktopd_orders

from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id

where website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand' 
Group by 1,2;



-- Step7: Under the situation when “gsearch” and “nonbrand, conducting A/B testing about “landing page
-- Step7-1: Identify where the test starts
select
    MIN(website_pageviews.website_pageview_id) AS first_test_pv
from website_pageviews
Where website_pageviews.pageview_url = '/lander-1';



-- Step 7-2: Under the situation when “gsearch” and “nonbrand , identifying the first page id that customers visit in each session after the test starts
Create temporary table first_test_pageviews_
select
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS first_test_pv
from website_sessions inner join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where  website_sessions.created_at < '2012-07-28'
	AND website_pageviews.website_pageview_id > 23504
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
Group by 1; 



-- Step7-3: Identify the first page name (home vs lander1) that customers visit in each session after the test starts
Create temporary table nonbrand_test_sessions_w_landing_page  
select
	 first_test_pageviews_ .website_session_id,
     website_pageviews.pageview_url AS landing_page
from first_test_pageviews_ 
	left join website_pageviews
    on first_test_pageviews_.first_test_pv = website_pageviews.website_pageview_id 
where website_pageviews.pageview_url in ('/home','/lander-1');



-- Step7-4: Identify the total orders number from home page and land-1 page separately  
-- bring nonbrand test session to orders 
Create temporary table nonbrand_test_sessions_w_orders
select
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    orders.order_id
from nonbrand_test_sessions_w_landing_page left join orders
	on nonbrand_test_sessions_w_landing_page.website_session_id = orders.website_session_id; 



-- Step7-5: Calculate different landing page has different order conversion rate
select landing_page,
		COUNT(website_session_id) AS sessions,
        COUNT(order_id) AS orders,
        COUNT(order_id)/COUNT(website_session_id) AS conversion
from nonbrand_test_sessions_w_orders
Group by 1;



-- Step7-6: Build conversion funnel to understand the effectiveness of two different landing pages under “gsearch ”and “nonbrand”

select
	website_sessions.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
	 CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	 CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
	 CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
     CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
     CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
     CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
     CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
     CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
from website_sessions left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at < '2012-07-28'
	AND website_sessions.created_at > '2012-06-19'
	AND utm_source = 'gsearch'
             AND utm_campaign = 'nonbrand';



-- Step8: Identify which part of customer journey toward to purchasing that customers made for each customer

Create temporary table session_made_it
select
	website_session_id,
    MAX(home_page) AS saw_home,
    MAX(lander_page) AS saw_lander,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_iy,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
from (select
	website_sessions.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
	 CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	 CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
	 CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
     CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
     CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
     CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
     CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
     CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
from website_sessions left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at < '2012-07-28'
	AND website_sessions.created_at > '2012-06-19'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand') AS ta
Group by 1;


Select
CASE WHEN saw_home = 1 THEN 'saw_homepage'
	 WHEN saw_lander = 1 THEN 'saw_lander'
     ELSE 'Oh...'
END AS Segment,
COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
COUNT(CASE WHEN mrfuzzy_made_iy = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
from session_made_it 
Group by 1;

select
CASE WHEN saw_home = 1 THEN 'saw_homepage'
	 WHEN saw_lander = 1 THEN 'saw_lander'
     ELSE 'Oh...'
END AS Segment,
COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
	/COUNT(website_session_id) AS lander_click_rt,
COUNT(CASE WHEN mrfuzzy_made_iy = 1 THEN website_session_id ELSE NULL END)
	/COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) 
	/COUNT(CASE WHEN mrfuzzy_made_iy = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) 
	/COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)  AS cart_click_rt,
COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) 
	/COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt,
COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) 
	/COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS thankyou_click_rt