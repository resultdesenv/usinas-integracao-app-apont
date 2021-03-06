import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class EstimativaModelo extends Equatable {
  final int cdEstagio;
  final String deEstagio;
  final int cdSafra;
  final int cdTpPropr;
  final String deTpPropr;
  final String cdUpnivel1;
  final String cdUpnivel2;
  final String cdUpnivel3;
  final int cdVaried;
  final String deVaried;
  final String dtUltimoCorte;
  final String instancia;
  final double precipitacao;
  final double qtAreaProd;
  final double producaoSafraAnt;
  final double sphenophous;
  final double tch0;
  final double tch1;
  final double tch2;
  final double tch3;
  final double tch4;
  final int cdFunc;
  final int noBoletim;
  final int noSeq;
  final int dispositivo;
  final String dtHistorico;
  final double tchAnoPassado;
  final double tchAnoRetrasado;
  final String status;
  final String dtStatus;

  EstimativaModelo({
    @required this.cdEstagio,
    @required this.deEstagio,
    @required this.cdSafra,
    @required this.cdTpPropr,
    @required this.deTpPropr,
    @required this.cdUpnivel1,
    @required this.cdUpnivel2,
    @required this.cdUpnivel3,
    @required this.cdVaried,
    @required this.deVaried,
    @required this.dtUltimoCorte,
    @required this.instancia,
    @required this.precipitacao,
    @required this.qtAreaProd,
    @required this.producaoSafraAnt,
    @required this.sphenophous,
    @required this.tch0,
    this.tch1,
    this.tch2,
    this.tch3,
    this.tch4,
    @required this.cdFunc,
    @required this.noBoletim,
    @required this.noSeq,
    @required this.dispositivo,
    @required this.dtHistorico,
    @required this.tchAnoPassado,
    @required this.tchAnoRetrasado,
    this.status = 'P',
    @required this.dtStatus,
  });

  factory EstimativaModelo.deMap(Map<String, dynamic> map) {
    return EstimativaModelo(
      cdEstagio: map['cdEstagio'],
      deEstagio: map['deEstagio'],
      cdSafra: map['cdSafra'],
      cdTpPropr: map['cdTpPropr'],
      deTpPropr: map['deTpPropr'],
      cdUpnivel1: map['cdUpnivel1'],
      cdUpnivel2: map['cdUpnivel2'],
      cdUpnivel3: map['cdUpnivel3'],
      cdVaried: map['cdVaried'],
      deVaried: map['deVaried'],
      dtUltimoCorte: map['dtUltimoCorte'],
      instancia: map['instancia'],
      precipitacao: map['precipitacao'],
      qtAreaProd: map['qtAreaProd'],
      producaoSafraAnt: map['producaoSafraAnt'],
      sphenophous: map['sphenophous'],
      tch0: map['tch0'],
      tch1: map['tch1'],
      tch2: map['tch2'],
      tch3: map['tch3'],
      tch4: map['tch4'],
      cdFunc: map['cdFunc'],
      noBoletim: map['noBoletim'],
      noSeq: map['noSeq'],
      dispositivo: map['dispositivo'],
      dtHistorico: map['dtHistorico'],
      tchAnoPassado: map['tchAnoPassado'],
      tchAnoRetrasado: map['tchAnoRetrasado'],
      status: map['status'],
      dtStatus: map['dtStatus'],
    );
  }

  EstimativaModelo copiarCom({
    int cdEstagio,
    int cdSafra,
    int cdTpPropr,
    String cdUpnivel1,
    String cdUpnivel2,
    String cdUpnivel3,
    int cdVaried,
    String dtUltimoCorte,
    String instancia,
    double precipitacao,
    double qtAreaProd,
    double producaoSafraAnt,
    double sphenophous,
    double tch0,
    double tch1,
    double tch2,
    double tch3,
    double tch4,
    int cdFunc,
    int noBoletim,
    int noSeq,
    int dispositivo,
    String dtHistorico,
    double tchAnoPassado,
    double tchAnoRetrasado,
    String status,
    String dtStatus,
  }) {
    return EstimativaModelo(
      cdEstagio: cdEstagio ?? this.cdEstagio,
      deEstagio: deEstagio ?? this.deEstagio,
      cdSafra: cdSafra ?? this.cdSafra,
      cdTpPropr: cdTpPropr ?? this.cdTpPropr,
      deTpPropr: deTpPropr ?? this.deTpPropr,
      cdUpnivel1: cdUpnivel1 ?? this.cdUpnivel1,
      cdUpnivel2: cdUpnivel2 ?? this.cdUpnivel2,
      cdUpnivel3: cdUpnivel3 ?? this.cdUpnivel3,
      cdVaried: cdVaried ?? this.cdVaried,
      deVaried: deVaried ?? this.deVaried,
      dtUltimoCorte: dtUltimoCorte ?? this.dtUltimoCorte,
      instancia: instancia ?? this.instancia,
      precipitacao: precipitacao ?? this.precipitacao,
      qtAreaProd: qtAreaProd ?? this.qtAreaProd,
      producaoSafraAnt: producaoSafraAnt ?? this.producaoSafraAnt,
      sphenophous: sphenophous ?? this.sphenophous,
      tch0: tch0 ?? this.tch0,
      tch1: tch1 ?? this.tch1,
      tch2: tch2 ?? this.tch2,
      tch3: tch3 ?? this.tch3,
      tch4: tch4 ?? this.tch4,
      cdFunc: cdFunc ?? this.cdFunc,
      noBoletim: noBoletim ?? this.noBoletim,
      noSeq: noSeq ?? this.noSeq,
      dispositivo: dispositivo ?? this.dispositivo,
      dtHistorico: dtHistorico ?? this.dtHistorico,
      tchAnoPassado: tchAnoPassado ?? this.tchAnoPassado,
      tchAnoRetrasado: tchAnoRetrasado ?? this.tchAnoRetrasado,
      status: status ?? this.status,
      dtStatus: dtStatus ?? this.dtStatus,
    );
  }

  Map<String, dynamic> paraMap() {
    return {
      'cdEstagio': cdEstagio,
      'deEstagio': deEstagio,
      'cdSafra': cdSafra,
      'cdTpPropr': cdTpPropr,
      'deTpPropr': deTpPropr,
      'cdUpnivel1': cdUpnivel1,
      'cdUpnivel2': cdUpnivel2,
      'cdUpnivel3': cdUpnivel3,
      'cdVaried': cdVaried,
      'deVaried': deVaried,
      'dtUltimoCorte': dtUltimoCorte,
      'instancia': instancia,
      'precipitacao': precipitacao,
      'qtAreaProd': qtAreaProd,
      'producaoSafraAnt': producaoSafraAnt,
      'sphenophous': sphenophous,
      'tch0': tch0,
      'tch1': tch1,
      'tch2': tch2,
      'tch3': tch3,
      'tch4': tch4,
      'cdFunc': cdFunc,
      'noBoletim': noBoletim,
      'noSeq': noSeq,
      'dispositivo': dispositivo,
      'dtHistorico': dtHistorico,
      'tchAnoPassado': tchAnoPassado,
      'tchAnoRetrasado': tchAnoRetrasado,
      'status': status,
      'dtStatus': dtStatus,
    };
  }

  @override
  List<Object> get props => [
        cdEstagio,
        deEstagio,
        cdSafra,
        cdTpPropr,
        deTpPropr,
        cdUpnivel1,
        cdUpnivel2,
        cdUpnivel3,
        cdVaried,
        deVaried,
        dtUltimoCorte,
        instancia,
        precipitacao,
        qtAreaProd,
        producaoSafraAnt,
        sphenophous,
        tch0,
        tch1,
        tch2,
        tch3,
        tch4,
        cdFunc,
        noBoletim,
        noSeq,
        dispositivo,
        dtHistorico,
        tchAnoPassado,
        tchAnoRetrasado,
        status,
        dtStatus,
      ];

  static List<Map<String, dynamic>> converterListaParaMap(
    List<EstimativaModelo> lista,
  ) {
    return lista.map((apontamento) => apontamento.paraMap()).toList();
  }

  static List<EstimativaModelo> converterListaMapObjeto(
    List<Map<String, dynamic>> lista,
  ) {
    return lista
        .map((apontamento) => EstimativaModelo.deMap(apontamento))
        .toList();
  }
}
