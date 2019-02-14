library(dplyr)
library(jsonlite)

areas <- fromJSON("https://api.obis.org/area")$results %>%
  filter(type == "iho") %>%
  mutate(id = as.numeric(id)) %>%
  select(areaid = id, areaname = name)

sp <- read.csv("woa.csv")

stats <- sp %>%
  group_by(speciesid, subphylumid, areaid, depth) %>%
  summarize(records = n()) %>%
  arrange(areaid, depth, desc(records)) %>%
  filter(is.na(subphylumid) | subphylumid != 146419) %>%
  left_join(areas, by = "areaid")

write.csv(stats, file = "stats.csv", row.names = FALSE, na = "")

areastats <- stats %>%
  group_by(areaname, depth) %>%
  summarize(records = sum(records), species = length(unique(speciesid)))

write.csv(areastats, file = "areastats.csv", row.names = FALSE, na = "")
