# goal: filter and select runs for _S. cerevisiae_ -Pi time course anlaysis
# author: Bin He
# date: 2022-10-07

# the csv file is downloaded from SRA run selector under two accessions: SRP113626 and SRP113638

require(tidyverse)

# import CSV
tb <- read_csv("Gurvich-2017-SraRunTable.csv")
dat <- tb %>% select(run = Run, name = `Library Name`, bases = Bases, exp = Experiment, sra = `SRA Study`)

use <- dat %>% 
  filter(grepl("0_06mM", name), grepl("WT_Rep", name), !grepl("L74F|recovery", name)) %>% 
  mutate(name = gsub("lowPi|tecRep|start", "XXX", name)) %>% 
  extract(name, c("group", "timepoint"), "(exp[12]).*XXX_([\\d_]*)h") %>% 
  mutate(timepoint = gsub("_", ".", timepoint)) %>% 
  arrange(group, as.numeric(timepoint))

write_tsv(use, file = "20221103-dataset-to-use.txt")
