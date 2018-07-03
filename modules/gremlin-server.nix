{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.gremlin.server;

  script = pkgs.writeTextFile {
    name = "server.groovy";
    text = cfg.script;
  };

  properties = pkgs.writeTextFile {
    name = "server.properties";
    text = ''
      gremlin.graph=org.apache.tinkerpop.gremlin.tinkergraph.structure.TinkerGraph
      gremlin.tinkergraph.vertexIdManager=UUID
    '' + pkgs.lib.optionalString cfg.loadDump ''
      gremlin.tinkergraph.graphFormat=graphson
      gremlin.tinkergraph.graphLocation=${cfg.dumpPath}
    '';
  };

  serverConf = pkgs.writeTextFile {
    name = "server.yaml";
    text = ''
      host: 0.0.0.0
      port: 8182
      scriptEvaluationTimeout: 30000
      threadPoolWorker: 4
      threadPoolBoss: 1
      gremlinPool: 8
      channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer
      serializers:
        - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { ioRegistries: [org.apache.tinkerpop.gremlin.tinkergraph.structure.TinkerIoRegistryV3d0] }} # application/vnd.gremlin-v3.0+gryo
        - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { serializeResultToString: true }} # application/vnd.gremlin-v3.0+gryo-stringd
        - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { useMapperFromGraph: graph }}        # application/json
        - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV3d0, config: { ioRegistries: [org.apache.tinkerpop.gremlin.tinkergraph.structure.TinkerIoRegistryV3d0] }} # application/vnd.gremlin-v3.0+json
      processors:
        - { className: org.apache.tinkerpop.gremlin.server.op.session.SessionOpProcessor, config: { sessionTimeout: 28800000 }}
        - { className: org.apache.tinkerpop.gremlin.server.op.traversal.TraversalOpProcessor, config: { cacheExpirationTime: 600000, cacheMaxSize: 1000 }}
        - { className: org.apache.tinkerpop.gremlin.server.op.standard.StandardOpProcessor, config: { maxParameters: 128 }}
      metrics: {
        jmxReporter: {enabled: true},
        graphiteReporter: {enabled: false, interval: 60000, host: graphite-relay.localdomain, port: 2003},
        consoleReporter: {enabled: false, interval: 180000},
        csvReporter: {enabled: false, interval: 180000, fileName: /tmp/gremlin-server-metrics.csv},
        slf4jReporter: {enabled: false, interval: 180000},
        gangliaReporter: {enabled: false, interval: 180000, addressingMode: MULTICAST}
      }
      strictTransactionManagement: false
      maxInitialLineLength: 4096
      maxHeaderSize: 8192
      maxChunkSize: 8192
      maxContentLength: 65536
      maxAccumulationBufferComponents: 1024
      resultIterationBatchSize: 64
      writeBufferLowWaterMark: 65536
      writeBufferHighWaterMark: 65536
      ssl: {
        enabled: false
      }
      graphs: {
        graph: ${properties}
      }
      scriptEngines: {
        gremlin-groovy: {
          plugins: { org.apache.tinkerpop.gremlin.server.jsr223.GremlinServerGremlinPlugin: {},
                     org.apache.tinkerpop.gremlin.tinkergraph.jsr223.TinkerGraphGremlinPlugin: {},
                     org.apache.tinkerpop.gremlin.jsr223.ScriptFileGremlinPlugin: { files: [${script}] }}}}
    '';
  };

in {

  options = {
    gremlin.server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      makeDump = mkOption {
        type = types.bool;
        default = true;
      };
      loadDump = mkOption {
        type = types.bool;
        default = true;
      };
      dumpPath = mkOption {
        type = types.path;
        description = "Location of GSON dump";
        default = "/tmp/dump.gson";
      };
      script = mkOption {
        type = types.string;
        description = "Server side groovy script";
        default = ''
          def globals = [:]
          globals << [g : graph.traversal()]
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.services.gremlinServer = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ] ++ (pkgs.lib.optional cfg.makeDump "gremlinDump.service");
        requires = pkgs.lib.optional cfg.makeDump "gremlinDump.service";
        script = "${contrailPkgs.tools.gremlinServer}/bin/gremlin-server ${serverConf}";
      };
    })
    (mkIf cfg.makeDump {
      systemd.services.gremlinDump = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "cassandra.service" ];
        script = "${contrailPkgs.tools.contrailGremlin}/bin/gremlin-dump --cassandra 127.0.0.1:9042 ${cfg.dumpPath}";
        serviceConfig = {
          Type = "oneshot";
        };
      };
    })
  ];

}
