package
{
    import cli.Application;
    import flash.utils.setTimeout;
    import tests.TestRun;

	public class Main extends Application
	{
		override protected function usage():void
		{
			super.usage();
			trace("  <file name>");
		}

        override protected function execute():void
        {
            var testRun:TestRun = new TestRun();
            testRun.run()
                .always(function():void {
                    exit(0);
                });
        }

	}
}
