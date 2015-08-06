cat $1 | awk ' BEGIN { found_dest=0 }
/HDFS_WRITE/ {
  if (found_dest == 0) {
    split($8,spl,":");
    split(spl[1],spl2,"/");
    dest_str=sprintf("%s",spl2[2]);
    found_dest=1;
  }

  split($6,spl,":");
  split(spl[1],spl2,"/");
  src_str=sprintf("%s-%d",spl2[2],$10);
  delays[src_str]+=$22;
  delays_cnt[src_str]++;
  srcs[spl2[2]]++;
  tot++;
  data_write[spl2[2]]+=$10
}
END {
  printf "Writes\n";
  for (i in srcs){
    total_write+=data_write[i]
  }
  for (i in srcs){
    if (i == dest_str)
      printf "Local %s %d %f%% %f%% %dMB\n",i,
        srcs[i],
        (srcs[i]/tot)*100,
        (data_write[i]/total_write)*100,
        data_write[i]/(1024*1024);
    else
      printf "Remote %s %d %f%% %f%% %dMB\n",i,
        srcs[i],
        (srcs[i]/tot)*100,
        (data_write[i]/total_write)*100,
         data_write[i]/(1024*1024);
  };
  printf "Total %d\n",total_write/(1024*1024);
} '
