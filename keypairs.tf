resource "aws_key_pair" "henryrocha_legionY740_manjaro_kp" {
  provider   = aws.region_01
  key_name   = "henryrocha-legionY740-manjaro-kp"
  public_key = file("/home/henryrocha/.ssh/aws_tf.pub")
}
