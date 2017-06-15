/*
 *
 * ©K. D. Hedger. Mon 12 Jun 12:02:04 BST 2017 kdhedger68713@gmail.com

 * This file (main.cpp) is part of LFSMakePkg.

 * Projects is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * at your option) any later version.

 * Projects is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with LFSMakePkg.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <ctype.h>

#define scriptsArg 1
#define rootArg 2
#define whatToDo 3
#define startArg 4

#define RED "\e[1;31m"
#define GREEN "\e[1;32m"
#define NORMAL "\e[0;0m"
#define BLUE "\e[1;34m"
#define BOLDBLACK "\e[1;38m"

#define	DELAY	75

enum {NONL=0,NLONERR,NLONOUT,NLONBOTH,CRONBOTH};

struct dependsStruct
{
	char*		scriptPath;
	char*		version;
	char*		name;
	char*		doWhat;
};

struct scriptsStruct
{
	char*		scriptPath;
	char*		dependsString;
	char*		version;
	char*		name;
	char*		installedVersion;
	bool		installed;
	bool		checked;
};

scriptsStruct	scripts[1000];
dependsStruct	dependsList[1000];

int				numScripts=0;
char*			scriptsFolder=NULL;
char*			rootFolder=NULL;
char*			libFolder=NULL;

int				numDepends=0;
const char*		spinner="-\\|/";

int				spincnt=0;
int				spindelay=0;

bool			quiet=false;
char			*strBuffer[PATH_MAX]={0,};
char			*pBuffer=(char*)&strBuffer;

char* cleanFolderPath(const char* path)
{
#if 1
	char		tpath[PATH_MAX]={0,};
	char		*cleanpath;
	bool		lastwasslash=false;
	unsigned	topos=0;

	for(int j=0;j<strlen(path);j++)
		{
			if(path[j]!='/')
				{
					tpath[topos]=path[j];
					topos++;
					lastwasslash=false;
				}
			else
				{
					if(lastwasslash==false)
						{
							tpath[topos]=path[j];
							topos++;
							lastwasslash=true;
						}
				}
		}

	if(tpath[topos-1]!='/')
		tpath[topos++]='/';

	tpath[topos]=0;
	return(strdup((char*)tpath));
#else
	char		*tpath[PATH_MAX]={0,};
	char		*cleanpath;

	realpath(path,(char*)tpath);
	if(strlen((char*)tpath)==1)
		asprintf(&cleanpath,"/");
	else
		asprintf(&cleanpath,"%s/",tpath);
	return(cleanpath);
#endif
}

void printOut(const char* serr,const char* sout,int newlinewhere)
{
	if(serr!=NULL)
		fprintf(stderr,"%s",serr);
	if(sout!=NULL)
		fprintf(stdout,"%s",sout);

	switch(newlinewhere)
		{
			case NLONERR:
				fprintf(stderr,"\n");
				break;
			case NLONOUT:
				fprintf(stdout,"\n");
				break;
			case NLONBOTH:
				fprintf(stdout,"\n");
				fprintf(stderr,"\n");
				break;
			case CRONBOTH:
				fprintf(stdout,"\r");
				fprintf(stderr,"\r");
				break;
		}
}

char* getDependsFromData(char* data)
{
	char* startchar=NULL;
	char* endchar=NULL;

	startchar=strcasestr(data,"DEPENDS=");
	if(startchar==NULL)
		return(NULL);
	startchar=(char*)(long)startchar+9;
	endchar=strchr(startchar,'"');

	for(int j=0; j<(int)((long)endchar-(long)startchar); j++)
		{
			if(startchar[j]=='\n')
				startchar[j]=' ';
		}
	return(strndup(startchar,(long)endchar-(long)startchar));
}


char* getNameFromData(char* data)
{
	char* startchar;
	char* endchar;

	startchar=strcasestr(data,"PKGNAME=");
	startchar=(char*)(long)startchar+9;
	endchar=strchr(startchar,'"');

	return(strndup(startchar,(long)endchar-(long)startchar));
}

char* getVersionFromData(char* data)
{
	char* startchar;
	char* endchar;

	startchar=strcasestr(data,"VERSION=");
	startchar=(char*)(long)startchar+9;
	endchar=strchr(startchar,'"');

	return(strndup(startchar,(long)endchar-(long)startchar));
}

void checkInstalled(void)
{
	char*	command;
	char	line[1024];
	FILE*	fp;
	char*	dash;
	char*	version;

	asprintf(&command,"find %s -mindepth 2 -iname \"%s-[0-9]*\" 2>/dev/null",libFolder,scripts[numScripts].name);
	fp=popen(command,"r");
	line[0]=0;
	fgets(line,1024,fp);
	if(strlen(line)>0)
		{
			dash=strrchr(line,'-');
			line[(long)dash-(long)line]=0;
			dash=strrchr(line,'-');
			dash=(char*)(long)dash+1;
			version=strdup(dash);
			scripts[numScripts].installed=true;
			scripts[numScripts].installedVersion=version;
		}
	else
		{
			scripts[numScripts].installed=false;
			scripts[numScripts].installedVersion=NULL;
		}
	free(command);
	pclose(fp);
}

void getData(void)
{
	char	line[2048];
	int		fd;
	int 	dataread=-1;
	char	*scriptpath=NULL;

	asprintf(&scriptpath,"%s%s",rootFolder,scripts[numScripts].scriptPath);
	fd=open(scriptpath,O_RDONLY);
	if(fd!=-1)
		{
			dataread=read(fd,&line[0],2047);
			if(dataread==-1)
				{
					printOut(RED "ERROR " NORMAL "Can't read any data from ",scripts[numScripts].scriptPath,NLONOUT);
					close(fd);
					exit(200);
				}

			line[dataread-1]=0;
			scripts[numScripts].name=getNameFromData(line);
			scripts[numScripts].version=getVersionFromData(line);
			scripts[numScripts].dependsString=getDependsFromData(line);
			checkInstalled();
			close(fd);
		}
	else
		{
			printOut(RED "ERROR " NORMAL "Can't open file ",scripts[numScripts].scriptPath,NLONOUT);
			exit(200);
		}
	free(scriptpath);
}

void getScripts(void)
{
	char		*command;
	char		line[1024];
	FILE		*fp;
	char		*sf=NULL;
	unsigned	offset=0;

	if(strlen(rootFolder)>1)
		offset=strlen(rootFolder)-1;

	asprintf(&command,"find %s -mindepth 3 -maxdepth 3 -iname \"*.LFSBuild\" |sort",scriptsFolder);
	fp=popen(command,"r");
	while(fgets(line,1024,fp)!=NULL)
		{
			line[strlen(line)-1]=0;
			scripts[numScripts].scriptPath=strdup(&line[offset]);
			scripts[numScripts].checked=false;
			getData();
			numScripts++;

			fprintf(stderr,GREEN "Locating scripts " NORMAL "%c\r",spinner[spincnt]);
			spindelay++;
			if(spindelay>DELAY)
				{
					spindelay=0;
					spincnt++;
					if(spincnt==4)
						spincnt=0;
				}
		}
	pclose(fp);
	free(command);
	printf("\n");
}

int getScriptStructFromName(char* name)
{
	int	retval=-1;
	for(int j=0; j<numScripts;j++)
		{
			if(strcasecmp(scripts[j].name,name)==0)
				{
					retval=j;
					break;
				}
		}

	return(retval);
}

int checkversionnumber(char* v1,char* v2)
{
	double	realvers1;
	double	realvers2;
	char*	holdstr;
	char*	saveptr;
	double	mult;
	int		result;

	holdstr=strdup(v1);
	strtok_r(holdstr,".",&saveptr);
	mult=10000000000;
	do
		{
			realvers1=realvers1+(atoi(holdstr)*mult);
			mult=mult/1000;
		}
	while((holdstr=strtok_r(NULL,".",&saveptr))!=NULL);
	free(holdstr);

	holdstr=strdup(v2);
	strtok_r(holdstr,".",&saveptr);
	mult=10000000000;
	do
		{
			realvers2=realvers2+(atoi(holdstr)*mult);
			mult=mult/1000;
		}
	while((holdstr=strtok_r(NULL,".",&saveptr))!=NULL);
	free(holdstr);

	mult=realvers1-realvers2;

	if(mult>0)
		result=1;

	if(mult==0)
		result=0;

	if(mult<0)
		result=-1;

	return(result);
}

char* chompedStr(char* str)
{
	char*	newstr;
	long	start;
	long	end;

	start=0;
	while(isspace(str[start])!=false)
		start++;

	end=strlen(str)-1;
	while(isspace(str[end])!=false)
		end--;

	newstr=strndup(&str[start],end-start+1);
	return(newstr);
}

int multiCheck(char* want,char* installed,char* inscript)
{
	double	realvers1;
	double	realvers2;
	double	realvers3;
	char*	holdstr;
	char*	saveptr;
	double	mult;
	int		result;

	holdstr=strdup(want);
	strtok_r(holdstr,".",&saveptr);
	mult=10000000000;
	do
		{
			realvers1=realvers1+(atoi(holdstr)*mult);
			mult=mult/1000;
		}
	while((holdstr=strtok_r(NULL,".",&saveptr))!=NULL);
	free(holdstr);

	holdstr=strdup(installed);
	strtok_r(holdstr,".",&saveptr);
	mult=10000000000;
	do
		{
			realvers2=realvers2+(atoi(holdstr)*mult);
			mult=mult/1000;
		}
	while((holdstr=strtok_r(NULL,".",&saveptr))!=NULL);
	free(holdstr);


	holdstr=strdup(inscript);
	strtok_r(holdstr,".",&saveptr);
	mult=10000000000;
	do
		{
			realvers3=realvers3+(atoi(holdstr)*mult);
			mult=mult/1000;
		}
	while((holdstr=strtok_r(NULL,".",&saveptr))!=NULL);
	free(holdstr);

	if((realvers1-realvers2)<=0)
		{
			return(0);
		}

	if((realvers1-realvers3)<=0)
		{
			return(1);
		}
	else
		{
			return(-1);
		}
}

void listDepends(char* depstr)
{
	char*			holdstr;
	char*			wantname=NULL;
	char*			wantversion=NULL;
	char*			dash=NULL;
	bool			gotit;
	int				scriptnum;
	char*			saveptr;
	int				versres;
	char*			strippedstring;

	holdstr=strdup(depstr);
	strtok_r(holdstr," ",&saveptr);

	do
		{
			strippedstring=chompedStr(holdstr);
			dash=strrchr(strippedstring,'-');

			if((dash!=NULL) && (isdigit(dash[1])==true))
				{
					wantversion=strdup(&dash[1]);
					wantname=strndup(strippedstring,(long)dash-(long)strippedstring);
				}
			else
				{
					wantname=strdup(strippedstring);
					wantversion=strdup("0");
				}

			gotit=false;
			for(int j=0; j<numDepends; j++)
				{
					if(strcasecmp(dependsList[j].name,wantname)==0)
						{
							gotit=true;
							break;
						}
				}

			if(gotit==false)
				{
					scriptnum=getScriptStructFromName(wantname);
					if(scripts[scriptnum].checked==true)
						return;
					if(scriptnum==-1)
						{
							fprintf(stderr,"\r" RED "ERROR " NORMAL "No available build script for %s\n" NORMAL,strippedstring);
							exit(400);
						}
					else
						{
							if((scripts[scriptnum].dependsString!=NULL) && (scripts[scriptnum].checked==false))
								{
									if(scripts[scriptnum].checked==true)
										return;
									else
										{
											scripts[scriptnum].checked=true;
											listDepends(scripts[scriptnum].dependsString);
										}
								}
						}
					dependsList[numDepends].name=strdup(wantname);
					dependsList[numDepends].version=strdup(wantversion);
					dependsList[numDepends].scriptPath=scripts[scriptnum].scriptPath;
					if(quiet==false)
						{
							printOut(BLUE "\rFound dependency " NORMAL,strippedstring,NLONOUT);
						}

					if(scripts[scriptnum].installed==true)
						{
							int result=multiCheck(wantversion,scripts[scriptnum].installedVersion,scripts[scriptnum].version);
							switch(result)
								{
								case 0:
									break;
								case 1:
									asprintf(&dependsList[numDepends].doWhat,"%s upgrade",dependsList[numDepends].scriptPath);
									break;
								case -1:
									fprintf(stderr,"\r" RED "ERROR " NORMAL "Version of build script " GREEN "%s" NORMAL "is to low for dependency " BLUE "%s\n" NORMAL,dependsList[numDepends].scriptPath,strippedstring);
									exit(100);
									break;
								}
						}
					else
						{
							if(checkversionnumber(wantversion,scripts[scriptnum].version)<=0)
								{
									asprintf(&dependsList[numDepends].doWhat,"%s install",dependsList[numDepends].scriptPath);
								}
							else
								{
									fprintf(stderr,"\r" RED "ERROR " NORMAL "Version of build script " GREEN "%s" NORMAL "is to low for dependency " BLUE "%s\n" NORMAL,dependsList[numDepends].scriptPath,strippedstring);
									exit(200);
								}
						}
					numDepends++;
				}

			free(wantname);
			free(wantversion);
			free(strippedstring);
		}
	while((holdstr=strtok_r(NULL," ",&saveptr))!=NULL);

	free(holdstr);
}

//argv[1]=scriptfolder
//argv[2]#rootfolder
//argv[3]=what to do
//argv[4..n]=getdeps
int main(int argc, char **argv)
{
	char	*correctedArgv;
	char	*tstr[PATH_MAX];

	if((argv[whatToDo][0]!='I') && (argv[whatToDo][0]!='L') && (argv[whatToDo][0]!='U'))
		{
			if((argv[startArg]==NULL) || (strlen(argv[startArg])==0))
				return(0);
			correctedArgv=strdup(argv[startArg]);

			for(int j=0; j<strlen(correctedArgv); j++)
				{
					if(correctedArgv[j]=='\n')
						correctedArgv[j]=' ';
					if(correctedArgv[j]=='\t')
						correctedArgv[j]=' ';
				}
		}

	pBuffer=(char*)strBuffer;

	rootFolder=cleanFolderPath(argv[rootArg]);
	sprintf(pBuffer,"%s/var/lib/lfspkg/packages",rootFolder);
	libFolder=cleanFolderPath(pBuffer);
	sprintf(pBuffer,"%s%s",rootFolder,argv[scriptsArg]);
	scriptsFolder=cleanFolderPath(pBuffer);

//printf("rootFolder=%s\n",rootFolder);
//printf("libFolder=%s\n",libFolder);
//printf("scriptsFolder=%s\n",scriptsFolder);
//exit(0);
	getScripts();

	switch(argv[whatToDo][0])
		{
//get dependency build scripts
		case 'G':
			quiet=true;
			listDepends(correctedArgv);
			for(int j=0; j<numDepends; j++)
				{
					if(dependsList[j].doWhat!=NULL)
						printf("%s\n",dependsList[j].doWhat);
				}
			break;

		case 'D':
			quiet=false;
			listDepends(correctedArgv);
			break;

		case 'B':
			quiet=true;
			listDepends(correctedArgv);
			for(int j=0; j<numDepends; j++)
				{
					if(dependsList[j].doWhat!=NULL)
						printf("%s\n",dependsList[j].doWhat);
				}
			break;

//list all packages data
		case 'L':
			for(int j=0; j<numScripts; j++)
				{
					printf("\n");
					printf("Package name=%s\n",scripts[j].name);
					printf("Script version=%s\n",scripts[j].version);
					printf("Path to script=%s\n",scripts[j].scriptPath);
					if(scripts[j].dependsString!=NULL)
						printf("Depends=%s\n",scripts[j].dependsString);
					else
						printf("Depends=NONE\n");
					
					if(scripts[j].installed==true)
						{
							printf("Installed=true\n");
							printf("Installed version=%s\n",scripts[j].installedVersion);
						}
					else
						{
							printf("Installed=false\n");
							printf("Installed version=-1\n");
						}
				}
			break;

//list installed pakages data
		case 'I':
			for(int j=0; j<numScripts; j++)
				{
					if(scripts[j].installed==true)
						{
							printf("\n");
							printf("Package name=%s\n",scripts[j].name);
							printf("Script version=%s\n",scripts[j].version);
							printf("Path to script=%s\n",scripts[j].scriptPath);
							if(scripts[j].dependsString!=NULL)
								printf("Depends=%s\n",scripts[j].dependsString);
							else
								printf("Depends=NONE\n");								
							printf("Installed version=%s\n",scripts[j].installedVersion);
						}
				}
			break;

//list uninstalled packages
		case 'U':
			for(int j=0; j<numScripts; j++)
				{
					if(scripts[j].installed==false)
						{
							printf("\n");
							printf("Package name=%s\n",scripts[j].name);
							printf("Script version=%s\n",scripts[j].version);
							printf("Path to script=%s\n",scripts[j].scriptPath);
							if(scripts[j].dependsString!=NULL)
								printf("Depends=%s\n",scripts[j].dependsString);
							else
								printf("Depends=NONE\n");								
						}
				}
			break;
//find package data
		case 'F':
			for(int j=0; j<numScripts; j++)
				{
					if(strncasecmp(argv[startArg],scripts[j].name,strlen(argv[startArg]))==0)
						{
							printf("\n");
							printf("Package name=%s\n",scripts[j].name);
							printf("Script version=%s\n",scripts[j].version);
							printf("Path to script=%s\n",scripts[j].scriptPath);
							if(scripts[j].dependsString!=NULL)
								printf("Depends=%s\n",scripts[j].dependsString);
							else
								printf("Depends=NONE\n");								
							if(scripts[j].installed==true)
								{
									printf("Installed=true\n");
									printf("Installed version=%s\n",scripts[j].installedVersion);
								}
							else
								printf("Installed=false\n");
						}
				}
			break;
		}
	free(rootFolder);
	free(libFolder);
	free(scriptsFolder);
}



