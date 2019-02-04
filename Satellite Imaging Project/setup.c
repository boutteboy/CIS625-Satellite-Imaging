#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

int main(int argc, char *argv[])
{
	int n = 0, i = 0;
	DIR *d;
	struct dirent *dir;
	d = opendir(argv[1]);

	FILE *fp;
	FILE *shfp;
	int size = 0;

	printf("About to get number of files\n");
	fflush(stdout);

	//Determine the number of files
	while((dir = readdir(d)) != NULL) 
	{
		if ( !strcmp(dir->d_name, ".") || !strcmp(dir->d_name, ".."))
		{

		} 
		else
		{
			n++;
		}
	}
	rewinddir(d);

	printf("Got number of files\n");
	fflush(stdout);

	char *filesList[n];
	int tileNum[n];

	printf("Created array\n");
	fflush(stdout);

	//Put file names into the array
	while((dir = readdir(d)) != NULL) {
		if ( !strcmp(dir->d_name, ".") || !strcmp(dir->d_name, ".."))
		{}
		else {
			filesList[i] = (char*) malloc(strlen(dir->d_name)+1);
			strncpy(filesList[i], dir->d_name, strlen(dir->d_name));
			sscanf(dir->d_name, "tile_%d_ndvi_fill.csv", &tileNum[i]);
			i++;
		}
	}

	printf("Wrote filenames to array\n");
	fflush(stdout);

	rewinddir(d);
	int j = 0;
	int timeVar = 0;
	char *times[n];
	char buffer[50];

	//Get filesize and use it to calculate time for the job
	while(j < n)
	{
		sprintf(buffer, "%s/%s", argv[1], filesList[j]);
		fp = fopen(buffer, "r");
		if (fp == NULL)
		{
			printf("\nFile unable to open ");
		}
		fseek(fp,0,2);
		size = ftell(fp) / 1024;
		timeVar = size * 0.15;

		//Logic to determine time the job will take
		int hours = 0;
		int minutes = 0;
		times[j] = (char*) malloc(11*sizeof(char));

		while (timeVar >= 3600)
		{
			timeVar -= 3600;
			hours++;
		}
		while (timeVar >= 60)
		{
			timeVar -= 60;
			minutes++;
		}

		if (minutes > 0)
		{
			hours ++;
			minutes = 30;
			timeVar = 0;
		}
		if (timeVar > 0)
		{
			minutes = 30;
			timeVar = 0;
		}

		if (hours < 10)
		{
			sprintf(buffer, "0%d:", hours);
			strcat(times[j], buffer);
		}
		else
		{
			sprintf(buffer, "%d:", hours);
			strcat(times[j], buffer);
		}
		if (minutes < 10)
		{
			sprintf(buffer, "0%d:00", minutes);
			strcat(times[j], buffer);
		}
		else
		{
			sprintf(buffer, "%d:00", minutes);
			strcat(times[j], buffer);
		}
			
		printf("%s, %d, %d KB, %s\n", filesList[j], tileNum[j], size, times[j]);
		fclose(fp);
		
		j++;
	}

	shfp = fopen("ndvi_sbatch.sh", "w");
	
	fprintf(shfp, "#!/bin/sh\n\n");
	
	for(i=0; i<n; i++)
	{
		int temp = tileNum[i];
		if (temp < 10)
		{
			fprintf(shfp, "sbatch --ntasks=20 --nodes=1 --mem-per-cpu=1G --job-name=bfast_00%d --mail-type=ALL --mail-user=boutteboy@ksu.edu --output=Output/bp_00%d.out --time=%s \"$HOME/Satellite Project/tile_run.sh\" %s/ tile_00%d\n", temp, temp, times[i], argv[1], temp);
		}
		else if (temp < 100)
		{
			fprintf(shfp, "sbatch --ntasks=20 --nodes=1 --mem-per-cpu=1G --job-name=bfast_0%d --mail-type=ALL --mail-user=boutteboy@ksu.edu --output=Output/bp_0%d.out --time=%s \"$HOME/Satellite Project/tile_run.sh\" %s/ tile_0%d\n", temp, temp, times[i], argv[1], temp);
		}
		else 
		{
			fprintf(shfp, "sbatch --ntasks=20 --nodes=1 --mem-per-cpu=1G --job-name=bfast_%d --mail-type=ALL --mail-user=boutteboy@ksu.edu --output=Output/bp_%d.out --time=%s \"$HOME/Satellite Project/tile_run.sh\" %s/ tile_%d\n", temp, temp, times[i], argv[1], temp);
		}
	}
	
	fclose(shfp);

	return 0;
}