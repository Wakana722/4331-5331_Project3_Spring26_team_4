import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.security.auth.login.Configuration;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import javafx.scene.shape.Path;

public class Task1 {

    public static class MovieMapper extends Mapper<Object, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private Text outputKey = new Text();

        public void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            try {
                String[] fields = value.toString().split(";");

                if (fields.length < 6) return;

                String type = fields[1];
                int year = Integer.parseInt(fields[3]);
                double rating = Double.parseDouble(fields[4]);
                String genresStr = fields[5];

                if (!type.equals("movie") || rating < 7.0) return;

                String period = null;
                if (year >= 1991 && year <= 2000)
                    period = "[1991-2000]";
                else if (year >= 2001 && year <= 2010)
                    period = "[2001-2010]";
                else if (year >= 2011 && year <= 2020)
                    period = "[2011-2020]";
                else
                    return;

                Set<String> genres = new HashSet<>(Arrays.asList(genresStr.split(",")));

                if (genres.contains("Action") && genres.contains("Thriller")) {
                    outputKey.set(period + ",Action;Thriller");
                    context.write(outputKey, one);
                }

                if (genres.contains("Adventure") && genres.contains("Drama")) {
                    outputKey.set(period + ",Adventure;Drama");
                    context.write(outputKey, one);
                }

                if (genres.contains("Comedy") && genres.contains("Romance")) {
                    outputKey.set(period + ",Comedy;Romance");
                    context.write(outputKey, one);
                }

            } catch (Exception e) {
                // skip bad rows
            }
        }
    }

    public static class SumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values, Context context)
                throws IOException, InterruptedException {

            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }

            result.set(sum);
            context.write(key, result);
        }
    }

    public static void main(String[] args) throws Exception {

        if (args.length != 2) {
            System.err.println("Usage: Task1 <input> <output>");
            System.exit(-1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Task1");

        job.setJarByClass(Task1.class);
        job.setMapperClass(MovieMapper.class);
        job.setCombinerClass(SumReducer.class);
        job.setReducerClass(SumReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}