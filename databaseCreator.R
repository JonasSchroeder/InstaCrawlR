#------------------------------------------------------
# Part of InstaCrawlR
# Git Hub: https://github.com/JonasSchroeder/InstaCrawlR
# Code by Jonas Schröder
# See ReadME for instructions and examples
# Updated September 2019
#------------------------------------------------------

library(readr)
library(rlist)
library(stringr)
library(rvest)
library(readr)
library(tidyverse)
library(ggplot2)


#---------------------------------------
# Functions to extract POST meta data
# @handle of author
# number of likes and comments
#---------------------------------------

extractMetaDataPost <- function(index){
    for(i in index:length(url_post_list)){
        print(index)
        url <- url_post_list[[i]]
        error <- tryCatch(
            source_temp <- read_lines(url),
            error=function(e) e
        )
        #no error
        if(!inherits(error, "error")){
            #source_temp <- read_lines(url_post_list[53])
            for(i in 1:length(source_temp)){
                
                # Extract date and time of post
                timestamp <- str_extract(source_temp[i], "taken_at_timestamp\":[:digit:]*") %>%
                    str_remove("taken_at_timestamp") %>%
                    str_remove("\":")
                if(is.na(timestamp) == F){
                    datetime_temp <- as.POSIXct(as.numeric(timestamp), origin="1970-01-01")
                    #print(datetime_temp)
                    post_datetime[index] <- datetime_temp
                }
                
                if(str_sub(source_temp[i], 2, 49) == "script type=\"text/javascript\">window._sharedData"){
                    # Sponsored Post
                    sponsor_temp <- unlist(str_split(source_temp[i], "sponsor")[[1]][3]) 
                    
                    if(is.na(sponsor_temp)){
                        # Post not sponsored
                        post_sponsor[index] <- "not sponsored"
                    } else {
                        #Get Profile from ID using https://www.instagram.com/web/friendships/USER-ID/follow/
                        sponsor_temp <- str_split(sponsor_temp, "location")[[1]][1] 
                        post_sponsor[index] <- str_split(sponsor_temp, "\"")[[1]][5] 
                    }
                    
                    
                    # Text
                    text_temp <- unlist(str_split(source_temp[i], "edge_media_to_caption")[[1]][2] %>%
                                            str_split("caption_is_edited"))[1] %>%
                        str_sub(30, -8)
                    #print(text_temp)
                    post_text[index] <- text_temp
                    
                    
                    # Hashtags in Text
                    post_hashtags_temp <- paste(unlist(str_extract_all(text_temp, 
                                                                       "#([A-Za-z0-9_](?:(?:[A-Za-z0-9_]|(?:\\.(?!\\.))){0,28}(?:[A-Za-z0-9_]))?)")), collapse = ' ')
                    
                    if(post_hashtags_temp == "character(0)"){
                        post_hashtags[index] <- "No Hashtags"
                    } else {
                        post_hashtags[index] <- post_hashtags_temp
                    }
                    
                    
                    # Mentions in Text
                    post_mentions_temp <- paste(unlist(str_extract_all(text_temp, 
                                                                 "@([A-Za-z0-9_](?:(?:[A-Za-z0-9_]|(?:\\.(?!\\.))){0,28}(?:[A-Za-z0-9_]))?)")), collapse = ' ')
                    
                    if(length(post_mentions_temp) == 0){
                        post_mentions[index] <- "No Mentions"
                    } else {
                        post_mentions[index] <- post_mentions_temp
                    }
                }
                
                
                if(str_sub(source_temp[i], 6, 17) == "meta content"){
                    #author is always the first @handle
                    profile_temp <- str_extract(source_temp[i], 
                                                "@([A-Za-z0-9_](?:(?:[A-Za-z0-9_]|(?:\\.(?!\\.))){0,28}(?:[A-Za-z0-9_]))?)")
                    # post content preview
                    #text_temp <- str_extract(source_temp[i], "“(.*?)”") %>%
                    #    str_remove("“") %>%
                    #    str_remove("”")
                    
                    
                    #number of likes (nol), number of comments (noc)
                    nol_temp <- cleanNum(str_extract(source_temp[i], "[:digit:]*[:punct:]?[:digit:]*[:alpha:]?[:space:]Likes") %>%
                                             str_remove("\"") %>%
                                             str_sub(1, -7))
                    noc_temp <- cleanNum(str_extract(source_temp[i], "[:digit:]*[:punct:]?[:digit:]*[:alpha:]?[:space:]Comments") %>%
                                             str_remove("\"") %>%
                                             str_sub(1, -10))
                    
                    #print(profile_temp)
                    #print(text_temp)
                    #print(nol_temp)
                    #print(noc_temp)
                    
                    if(length(profile_temp) < 1){
                        print("some strange error")
                        insta_profiles[index] <- "strange error"
                    } else {
                        #no errors, save data
                        insta_profiles[index] <- profile_temp
                        #post_text[index] <- text_temp
                        post_likes[index] <- nol_temp
                        post_comments[index] <- noc_temp
                    }
                }
            }
            
        } else {
            print("Post is not available anymore")
            print(error)
            insta_profiles[index] <- "post deleted"
        }
        
        index <- index + 1
        assign("index", index, envir = .GlobalEnv)
        assign("insta_profiles", insta_profiles, envir = .GlobalEnv)
        assign("post_text", post_text, envir = .GlobalEnv)
        assign("post_sponsor", post_sponsor, envir = .GlobalEnv)
        assign("post_hashtags", post_hashtags, envir = .GlobalEnv)
        assign("post_mentions", post_mentions, envir = .GlobalEnv)
        assign("post_likes", post_likes, envir = .GlobalEnv)
        assign("post_comments", post_comments, envir = .GlobalEnv)
        assign("post_datetime", post_datetime, envir = .GlobalEnv)
        #Sys.sleep(2)
    }
}


# Extract Profile Infos
getProfileURL <- function(){
    for(i in 1:length(insta_profiles)){
        print(i)
        if(is.na(insta_profiles[i])){
            print("NA; not a post link")
            profile_url <- "not a post link"
        } else {
            if(insta_profiles[i] == "post deleted"){
                print("post deleted")
                profile_url <- "post deleted"
            } else {
                profile_name <- str_remove(insta_profiles[i], "@")
                profile_url <- str_glue("https://www.instagram.com/{profile_name}")
                print(profile_url)
            }
        }
        url_profile_list <- list.append(url_profile_list, profile_url)
    }
    return(url_profile_list) 
}

#------------------------------------------------------------------------------
# Functions to extract PROFILE meta data: Number of followers, following, posts
# Clean Data
# Later match data for unique list with larger list that contains duplicates 
#------------------------------------------------------------------------------

extractMetaDataProfile <- function(index){
    for(i in index:length(url_profile_list_unique)){
        print(index)
        # check for appropriate profile links
        if(url_profile_list_unique[i] != "post deleted" & url_profile_list_unique[i] != "not a post link"){
            url <- url_profile_list_unique[index]
            error <- tryCatch(
                profile <- read_lines(url),
                error=function(e) e
            )
            #no error
            if(!inherits(error, "error")){
                #profile <- read_lines(url)
                for(j in 1:length(profile)){
                    if(str_sub(profile[j], 14, 43) == "meta property=\"og:description\""){
                        #print("found line")
                        source_temp <- profile[j]
                        #print(source_temp)
                        meta <- strsplit(source_temp, "\"")[[1]][4] %>%
                            strsplit("[: :]") %>% unlist()
                        #print(meta)
                        
                        follower_unique[index] <- getNoFollower(meta)
                        following_unique[index] <- getNoFollowing(meta)
                        posts_unique[index] <- getNoPosts(meta)
                        
                        assign("follower_unique", follower_unique, envir = .GlobalEnv)
                        assign("following_unique", following_unique, envir = .GlobalEnv)
                        assign("posts_unique", posts_unique, envir = .GlobalEnv)
                        index <- index + 1
                    }
                }
            } else {
                # probably HTTP 429 return
                print("something's wrong with the url")
                print(error)
                
                # HTTP 404 error -> post not available anymore
                is404 <- str_extract(error, "404")
                is429 <- str_extract(error, "429")
                if(is.na(is404) == F){
                    # next
                    index <- index + 1
                }
                if(is.na(is429) == F){
                    Sys.sleep(30)
                }
            }
        } else {
            # No profile link extracted: either post not available or wrong link format (e.g. profile instead of post)
            print("Ignoring this element")
            index <- index + 1
        }
        
        assign("index", index, envir = .GlobalEnv)
        
        # optional: sleep to reduce risk of HTTP 429 returns
        Sys.sleep(1)
    }
}

getNoFollower <- function(meta){
    follower <- meta[1]
    #print(follower)
    if(length(cleanNum(follower) != 0)){
        follower <- cleanNum(follower)
        #print(follower)
        return(follower)
    } else {
        print("something's wrong: follower")
    }
}

getNoFollowing <- function(meta){
    following <- meta[3]
    if(length(cleanNum(following) != 0)){
        following <- cleanNum(following)
        #print(following)
        return(following)
    } else {
        print("something's wrong: following")
    }
}

getNoPosts <- function(meta){
    posts <- meta[5]
    if(length(cleanNum(posts) != 0)){
        posts <- cleanNum(posts)
        #print(posts)
        return(posts)
    } else {
        print("something's wrong: posts")
    }
}

cleanNum <- function(to_test){
    #clean <- as.numeric(to_test)
    if(str_detect(to_test, "\\.") & str_detect(to_test, "k")){
        clean <- str_remove(to_test, "\\.") %>%
            str_remove("k") %>%
            as.numeric() * 100
    } else if(str_detect(to_test, "\\.") & str_detect(to_test, "m")){
        clean <- str_remove(to_test, "\\.") %>%
            str_remove("m") %>%
            as.numeric() * 100000
    } else if(str_detect(to_test, "\\,")){
        clean <- str_remove(to_test, ",") %>%
            as.numeric()
    } else if(str_detect(to_test, "k")){
        clean <- str_remove(to_test, "k") %>%
            as.numeric() * 1000
    } else if(str_detect(to_test, "m")){
        clean <- str_remove(to_test, "m") %>%
            as.numeric() * 1000000
    } else {
        clean <- as.numeric(to_test)
    } 
    return(clean)
}

# Match Data from url_profile_list_unique with larger url_profile_list
matchProfileData <- function(index){
    for(i in 1:length(url_profile_list)){
        for(j in 1:length(url_profile_list_unique)){
            if(url_profile_list[i] == url_profile_list_unique[j]){
                follower[i] <- follower_unique[j]
                following[i] <- following_unique[j]
                posts[i] <- posts_unique[j]
                
                assign("follower", follower, envir = .GlobalEnv)
                assign("following", following, envir = .GlobalEnv)
                assign("posts", posts, envir = .GlobalEnv)
                
                break
            }
        }
    }
}

#----------------------------------------------------------------
# START SCRIPT HERE
#----------------------------------------------------------------

# Load Log Files and Import Your List of URLs
# German Excel uses ";" as separator -> read_csv2().
# If your Locale is EN, use read_csv() instead of read_csv2()
url_post_list <- unlist(read_csv2("instagram_url_test_list.csv"))

# alternative: import csv file from jsonReader.R and use column for post urls
# import <- read_csv("test.csv") 
# url_post_list <- import$Post_URL

# Optional: Take a Subset for Sampling / Testing (e.g., last 50 entries)
# url_post_list <- tail(url_post_list, 50)

# Extract Meta Data from Post: Author's @handle, Text, Hashtags, Mentions, Number of Likes and Comments, 
# Datetime, whether the Post is Sponsored or not (incl. user ID of the sponsoring company)
insta_profiles <- c()
post_text <- c()
post_mentions <- c()
post_hashtags <- c()
post_sponsor <- c()
post_likes <- c()
post_comments <- c()
post_datetime <- c()
index <- 1
extractMetaDataPost(index)


# Save List of Profiles and Post Links
# Note: NA created in extractMetaDataPost() when link in list is not a post link 
# Optional: Deleting Entries with "post deleted"
profile_save <- insta_profiles
post_url_save <- url_post_list

if(any(insta_profiles == "post deleted") == F){
    print("no deleted posts in url_post_list")
} else {
    #deleting posts is optional
    #url_post_list <- url_post_list[-which(insta_profiles == "post deleted")]
    #insta_profiles <- insta_profiles[-which(insta_profiles == "post deleted")]
}

# Get profile URL from @handle
url_profile_list <- list()
url_profile_list <- unlist(getProfileURL())

# Get Rid of Duplicates 
# Extract Profile Meta Data: Number of Followers, Following, Posts
url_profile_list_unique <- unique(url_profile_list)
follower_unique <- c()
following_unique <- c()
posts_unique <- c()
index <- 1
extractMetaDataProfile(index)

# Match Data for Export
follower <- c()
following <- c()
posts <- c()
index <- 1
matchProfileData(index)

# Combine and Export Data
export3 <- as.data.frame(cbind(insta_profiles, url_profile_list, follower, following, posts, 
                               unlist(url_post_list), post_text, post_mentions, post_hashtags, 
                               post_sponsor, post_datetime, post_likes, post_comments), row.names = F)
write.csv(export3, "database_test.csv", fileEncoding = "UTF-8", quote = T)


