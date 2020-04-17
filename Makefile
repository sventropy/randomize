all:
	cd src \
	&& dotnet clean \
	&& dotnet build \
	&& dotnet run \

clean: 
	cd src \
	&& dotnet clean