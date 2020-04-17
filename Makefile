all:
	cd src \
	&& dotnet clean \
	&& dotnet build \
	&& dotnet run \