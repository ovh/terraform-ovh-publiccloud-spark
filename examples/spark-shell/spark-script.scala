import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.feature.{OneHotEncoder, StandardScaler, StringIndexer, VectorAssembler}

sc.hadoopConfiguration.set("fs.swift.impl" , "org.apache.hadoop.fs.swift.snative.SwiftNativeFileSystem")
sc.hadoopConfiguration.set("fs.swift.service.tesla.auth.url","https://auth.cloud.ovh.net/v2.0/tokens")
sc.hadoopConfiguration.set("fs.swift.service.tesla.tenant","${os_tenant_name}")
sc.hadoopConfiguration.set("fs.swift.service.tesla.username", "${os_username}")
sc.hadoopConfiguration.set("fs.swift.service.tesla.password", "${os_password}")
sc.hadoopConfiguration.set("fs.swift.service.tesla.http.port", "443")
sc.hadoopConfiguration.set("fs.swift.service.tesla.region", "${os_region}")
sc.hadoopConfiguration.set("fs.swift.service.tesla.public", "true")

val source = spark.read.option("inferSchema","true").csv("swift://${swift_container_name}.tesla/${swift_object_name}")

val vectorizer = new VectorAssembler().setInputCols(Array("_c0")).setOutputCol("vectorized_c0");
val scaler = new StandardScaler().setInputCol("vectorized_c0").setOutputCol("scaled_c0");
val indexer = new StringIndexer().setInputCol("_c1").setOutputCol("indexed_" + "_c1").setHandleInvalid("keep");

val encoder = new OneHotEncoder().setInputCol("indexed_" + "_c1").setOutputCol("_ohe_" + "_c1");
val pipeline = new Pipeline().setStages(Array(vectorizer, scaler, indexer, encoder));
val target = pipeline.fit(source).transform(source)
source.write.parquet("swift://${swift_container_name}.tesla/${swift_object_name}_processed.parquet")
source.write.csv("swift://${swift_container_name}.tesla/${swift_object_name}_processed.csv")
  
