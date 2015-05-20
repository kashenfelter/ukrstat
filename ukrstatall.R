ukrstatall <- function(file="data/4. IV. ����� ������ ��������.xls") {
        library(xlsx); library(stringr); library(dplyr); library(zoo); library(tidyr)
        
        stats <- read.xlsx2(file, sheetIndex=1, startRow=7, header=F) ## 
        names(stats) <- c("country", "ei", "export_kol", "export_amount", "import_kol", "import_amount")
        stats$country[stats$country==""] <- NA ## replace all "" to NAs
        stats$country <- str_trim(na.locf(stats$country)) ##fill na with data from above and trim spaces
        
        period <- read.xlsx2(file, sheetIndex=1, startRow=3, endRow=3, header=F)
        period <- as.character(period[[1]])
        print(period)
        
        for(i in 3:6){ ##change class of column
                stats[,i] <- as.numeric(as.character(stats[,i]))
        }
        
        
        stats$ei <- sub("� 100 % ������", "100%spirit",stats$ei)
        stats$ei <- sub("��", "kg",stats$ei)
        stats$ei <- sub("�", "L",stats$ei)
        stats$ei <- sub("���. ��", "x1000pcs",stats$ei)
        stats$ei <- str_trim(stats$ei)
        
        stats$ei <- as.factor(stats$ei)
        
        kodesindex <- grep("^[0-9]{10}", stats$country) ##��������� ���� 10-������� �����
        
        stats$ukt <- NA
        for(i in kodesindex){
                stats$ukt[i] <- stats$country[i]
        }
        stats <- stats[-1,]
        stats$ukt <- na.locf(stats$ukt)
        
        
        
        todel <- c("������", "������ ���", "I��I ������ ��I��", "������", "�ǲ�", "������", "�������", "������˲� � ����Ͳ�", "��ز") ## �������� �� ��������
        del_others <- NULL
        for(i in 1:length(todel)){
                del_others <- c(del_others, grep(todel[i], stats$country)) ## ������ � ��������� ���� ��������� �� �������� � �������� �� ��� ������
        }
        
        stats <- stats[-del_others,] ## ������ �� ������� ��� ������ (���������) ��������� ���� "�ǲ�", "������" � �.�. �� �������
        kodesindex2 <- grep("^[0-9]{10}", stats$country) ##��������� ���� 10-������� �����
        stats <- stats[-kodesindex2,]
        
        stats$country <- as.factor(stats$country)
        stats$ukt <- as.factor(stats$ukt)
        
        stats <- gather(stats, destination_izmerenie, summa, -c(country, ei, ukt))
        stats <- separate(stats, col=destination_izmerenie, into = c("dest", "mera"))
        stats <- stats[!stats$ei=="" & stats$summa>0,] ##del rows w/o ei and summa
        
        stats$mera <- as.factor(stats$mera)
        stats$dest <- as.factor(stats$dest)
        
        per <- substr(period,nchar(period)-23,nchar(period))
        write.xlsx2(stats, paste(per,".xlsx"), row.names=F)
        
        
}