Update September 2019:
The script databaseCreator.R is working again. The previous version stopped working properly some time ago and left the lists mentions, hashtags, and text without values (NULL).

Update July 2019:
I can confirm that the scripts still use as intended. As a response to multiple requests on Twitter and LinkedIn I've updated the jsonReader.R script so it exports an additional column (post_URL) that you can directly feed as an input for databaseCreator.R

Update March 2019:
Instagram seems to change the structure of their response from time to time. I fixed the issue. Read more about it here: https://medium.com/@jonas.schroeder1991/update-instacrawlr-still-crawling-6500cd376ea3

Update October 2018: 
I added a new script (databaseCreator.R) which enables you to build your own Instagram database that you can use for Social Media Monitoring, comparing and selecting Influencers, or Competitive Analyses. databaseCreator scrapes Instagram based on a list of post URLs for Post Meta Data (text, hashtags, mentions, number of likes and comments) and Profile Meta Data (Author's @handle, number of followers, following, and posts). 

More about databaseCreator in this Medium article.https://medium.com/@jonas.schroeder1991/build-your-own-instagram-database-134281e8ee92

-----------

# InstaCrawlR
Crawl public Instagram data using R scripts without API access token.

Here's an example:
https://medium.com/@jonas.schroeder1991/social-network-analysis-of-related-hashtags-on-instagram-using-instacrawlr-46c397cb3dbe

Please consult "InstaCrawlR Instructions.pdf" for more information on what InstaCrawlR can and can't do and how to use it.

Jonas

---------

Instagram is constantly changing their API’s functionality (platform changelog). Following Facebook’s Cambridge Analytica incident and the resulting public pressure, the API use got restricted even more severely in April 2018. The new limit is now 200 calls per user per hour instead of 5,000. More restrictions are announced to become active in July and December 2018.

The company’s rational for restricting access to data is probably to prevent spamming behavior and data exploitation. However, since Social Media Platforms is now an integral part of everyday life, data gathered from these services have become more and more interesting for academic researchers.

In 2016, Instagram totally changed their API system. Developers have to submit their app to a rigorous permission review process in order to get an access token. Since academic researchers are not programming applications that are suitable for this review process (e.g., video-screen casting the app’s functionality from an end user’s point of view), they are basically unable to officially access valuable data for their research.

InstaCrawlR is a collection of R scripts that can be used to crawl public Instagram data without the need to have access to the official API. Its functionality is limited compared to what is possible using the official API. However, it seems to be the only option for non-developers to gather and analyze Instagram data.

Please note two things: As of July 2018, the scripts run as intended. This can change any time soon since Instagram is constantly limiting their API’s functionality. Also keep in mind that using these scripts can have legal consequences since Instagram does not allow automated scripts. I am not responsible for consequences of any kind.

USE AT YOUR OWN RISK. BE ETHICAL WITH USER DATA.

------------
    
**What it can do**


InstaCrawlR consist of four scripts – jsonReader, hashtagExtractor, graphCreator, and g2gephi – which are described in the instruction PDF. InstaCrawlR can be used to download and analyze the most recent posts for any specific hashtag that can be found on Instagram’s Explore page (instagram.com/explore/tags/HASHTAG/). More specifically it can:

• Download the most recent posts for any hashtag

• Export a csv file that shows post ID, URL, number of likes, post owner ID, post text,
and post date

• Automatically extract related hashtags from post text

• Images can be automatically downloaded, too

• Export related hashtags and frequency

• Create a graph showing the relationship of related hashtags (social network analysis)

• Export graph for further analysis in Gephi



**What it can’t**

• No specification of a certain timeframe (only most recent)

• No information on who liked the posts (only counter)

• Only post owner ID, not profile name

• Suspicious posts must be filtered out by hand using Excel

• No location information available

_Please consult the instructions PDF for details._

    
**Closing Words**

You can use the script or parts in your own code. Please note that I am not a professional developer or trained programmer. I am sure InstaCrawlR’s code can be simplified and improved a lot. Feel free to clean up my code or change it to increase its capabilities.
Again, use the scripts at your own risk. I am not reliable for any consequences. InstaCrawlR may only function for a limited time since Instagram is constantly changing their system. I will not necessarily support InstaCrawlR in the future.
If you have any comments or suggestions you can reach me on LinkedIn. I am always looking forward to a nice conversation about the future of digital marketing, entrepreneurship, and data science.

Best regards,
Jonas Schröder
University of Mannheim, July 2018
 
