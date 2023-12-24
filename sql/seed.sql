-- users
-- dark_mode
UPDATE users JOIN themes ON users.id = themes.user_id SET users.dark_mode = themes.dark_mode;
-- total_reactions
UPDATE users JOIN (SELECT user_id, COUNT(*) AS total_reactions FROM livecomments GROUP BY user_id) AS livecomments ON users.id = livecomments.user_id SET users.total_reactions = livecomments.total_reactions;
-- total_tips
UPDATE users JOIN (SELECT user_id, SUM(tip) AS total_tips FROM livecomments GROUP BY user_id) AS livecomments ON users.id = livecomments.user_id SET users.total_tips = livecomments.total_tips;
-- score
UPDATE users JOIN (SELECT user_id, IFNULL(SUM(tip) + COUNT(*), 0) AS score FROM livecomments GROUP BY user_id) AS livecomments ON users.id = livecomments.user_id SET users.score = livecomments.score;

-- livestreams
-- total_reactions
UPDATE livestreams JOIN (SELECT livestream_id, COUNT(*) AS total_reactions FROM reactions GROUP BY livestream_id) AS reactions ON livestreams.id = reactions.livestream_id SET livestreams.total_reactions = reactions.total_reactions;
-- total_tips
UPDATE livestreams JOIN (SELECT livestream_id, SUM(tip) AS total_tips FROM livecomments GROUP BY livestream_id) AS livecomments ON livestreams.id = livecomments.livestream_id SET livestreams.total_tips = livecomments.total_tips;
-- score
UPDATE livestreams JOIN (SELECT livestream_id, IFNULL(SUM(tip) + COUNT(*), 0) AS score FROM livecomments GROUP BY livestream_id) AS livecomments ON livestreams.id = livecomments.livestream_id SET livestreams.score = livecomments.score;
