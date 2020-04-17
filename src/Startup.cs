using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using GraphQL.Server;
using GraphQL.Server.Transports.AspNetCore;
using GraphQL.Server.Ui.GraphiQL;

namespace randomize
{
    public class Startup
    {
        public Startup(IConfiguration configuration, IWebHostEnvironment environment)
        {
            Configuration = configuration;
            Environment = environment;
        }

        public IConfiguration Configuration { get; }

        public IWebHostEnvironment Environment { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services
                .AddSingleton<RandomizeSchema>()
                .AddGraphQL(options =>
                {
                    options.EnableMetrics = Environment.IsDevelopment();
                    options.ExposeExceptions = Environment.IsDevelopment();
                    options.UnhandledExceptionDelegate = ctx => Console.WriteLine(ctx.OriginalException);
                })
                // Add required services for de/serialization
                .AddSystemTextJson(deserializerSettings => { }, serializerSettings => { }) // For .NET Core 3+
                                                                                           // .AddWebSockets() // Add required services for web socket support
                                                                                           // .AddDataLoader() // Add required services for DataLoader support
                .AddGraphTypes(typeof(RandomizeSchema)); // Add all IGraphType implementors in assembly which ChatSchema exists 
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseGraphQL<RandomizeSchema, GraphQLHttpMiddleware<RandomizeSchema>>("/graphql");
            app.UseGraphiQLServer(new GraphiQLOptions
            {
                GraphiQLPath = "/ui/graphiql",
                GraphQLEndPoint = "/graphql",
            });
        }


    }
}
