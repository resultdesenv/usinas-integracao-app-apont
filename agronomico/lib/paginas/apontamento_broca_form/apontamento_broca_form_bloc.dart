import 'package:agronomico/comum/modelo/apont_broca_model.dart';
import 'package:agronomico/comum/repositorios/apont_broca_consulta_repository.dart';
import 'package:agronomico/comum/repositorios/preferencia_repository.dart';
import 'package:agronomico/comum/repositorios/sequencia_repository.dart';
import 'package:agronomico/comum/repositorios/tipo_fitossanidade_consulta_repository.dart';
import 'package:agronomico/paginas/apontamento_broca_form/apontamento_broca_form_event.dart';
import 'package:agronomico/paginas/apontamento_broca_form/apontamento_broca_form_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:simple_moment/simple_moment.dart';

class ApontamentoBrocaFormBloc
    extends Bloc<ApontamentoBrocaFormEvent, ApontamentoBrocaFormState> {
  final ApontBrocaConsultaRepository repositorioBroca;
  final SincronizacaoSequenciaRepository repositorioSequencia;
  final TipoFitossanidadeConsultaRepository repositorioFitossanidade;
  final PreferenciaRepository repositorioPreferencia;

  ApontamentoBrocaFormBloc({
    @required this.repositorioBroca,
    @required this.repositorioSequencia,
    @required this.repositorioFitossanidade,
    @required this.repositorioPreferencia,
  }) : super(ApontamentoBrocaFormState());

  @override
  Stream<ApontamentoBrocaFormState> mapEventToState(
    ApontamentoBrocaFormEvent event,
  ) async* {
    if (event is IniciarFormBrocas) {
      try {
        yield state.juntar(carregando: true);
        final tiposFitossanidade = await repositorioFitossanidade.get();
        if (tiposFitossanidade.isEmpty)
          throw 'Não foram encontrados tipos de fitossanidade, sincronize e tente novamente!';

        final prefFitoss = await repositorioPreferencia.get(
          idPreferencia: 'tipo-fitossanidade',
        );
        final cdFitoss =
            (prefFitoss != null ? int.tryParse(prefFitoss) : null) ??
                tiposFitossanidade?.first?.cdFitoss;
        List<ApontBrocaModel> brocas = [];
        String mensagemErro;
        ApontBrocaModel primeiraBroca;

        final prefCana = await repositorioPreferencia.get(
          idPreferencia: 'quantidade-canas',
        );
        final int qtCana =
            (prefCana != null ? int.tryParse(prefCana) : prefCana) ?? 100;

        final sequencia = await repositorioSequencia.buscarSequencia(
          empresa: event.empresa,
          aplicacao: 116,
        );
        if (event.novoApontamento) {
          brocas = await repositorioBroca.get(
              filtros: Map.from({
            'cdUpnivel1': event.upnivel3.cdUpnivel1,
            'cdUpnivel2': event.upnivel3.cdUpnivel2,
            'cdUpnivel3': event.upnivel3.cdUpnivel3,
          }));

          if (event.novoApontamento && brocas.length > 0) {
            mensagemErro = 'Esse talhão ja possui um apontamento, abrindo...';
          } else {
            int noSeqAtual = 0;
            brocas = [];
            primeiraBroca = ApontBrocaModel.fromUpnivel3(
              event.upnivel3,
              instancia: event.instancia,
              noBoletin: 10000 + sequencia.sequencia + 1,
              noSequencia: ++noSeqAtual,
              dispositivo: event.dispositivo,
              cdFunc: event.cdFunc,
              cdFitoss: cdFitoss,
            );
          }
        } else {
          final Map<String, dynamic> filtros = Map();
          filtros['noBoletim'] = event.noBoletim;
          brocas = await repositorioBroca.get(filtros: filtros);
        }
        yield state.juntar(
          brocas: brocas,
          carregando: false,
          tiposFitossanidade: tiposFitossanidade,
          novoApontamento: mensagemErro == null ? event.novoApontamento : false,
          tipoFitossanidade: brocas.length > 0 || primeiraBroca != null
              ? primeiraBroca?.cdFitoss ?? brocas.first.cdFitoss
              : null,
          mensagemErro: mensagemErro,
          primeiraBroca: primeiraBroca,
          salvo: primeiraBroca == null,
          canas: brocas.length > 0 ? brocas.length : qtCana,
          sequencia: sequencia,
        );
      } catch (e) {
        print(e);
        yield state.juntar(
          mensagemErro: e.toString(),
          carregando: false,
        );
      }
    }

    if (event is AlteraTipoBroca) {
      try {
        final brocas = event.brocas
            .map((e) => e.juntar(cdFitoss: event.cdFitoss))
            .toList();
        yield state.juntar(brocas: brocas, salvo: false);
        await repositorioPreferencia.salvar(
          idPreferencia: 'tipo-fitossanidade',
          valorPreferencia: event.cdFitoss,
        );
      } catch (e) {
        print(e);
        yield state.juntar(mensagemErro: e.toString());
      }
    }

    if (event is AlteraApontamento) {
      final brocas = state.brocas;
      brocas[event.indiceBroca] = event.broca;
      yield state.juntar(brocas: brocas, salvo: false);
    }

    if (event is SalvarApontamentos) {
      yield state.juntar(carregando: true);
      final brocas = event.brocas
          .map((e) => e.juntar(
                qtCanasbroc: e.qtBrocados > 0 ? 1 : 0,
                qtCanas: 1,
                dtOperacao: Moment.now().format('yyyy-MM-dd'),
                dtStatus: Moment.now().format('yyyy-MM-dd'),
                hrOperacao: Moment.now().format('yyyy-MM-dd HH:mm:ss'),
                status: 'P',
              ))
          .toList();
      try {
        await repositorioBroca.salvar(brocas);

        if (state.novoApontamento) {
          await repositorioSequencia.salvarSequencia(
            sequencia: state.sequencia.juntar(
              sequencia: state.sequencia.sequencia + 1,
            ),
          );
        }

        if (state.novoApontamento) {
          final sequencia = await repositorioSequencia.buscarSequencia(
            empresa: event.empresa,
          );
          await repositorioSequencia.salvarSequencia(
            sequencia: sequencia.juntar(sequencia: sequencia.sequencia + 1),
          );
        }

        yield state.juntar(
          carregando: false,
          voltarParaListagem: event.voltar,
          brocas: brocas,
          salvo: true,
        );
      } catch (e) {
        print(e);
        yield state.juntar(
          carregando: false,
          mensagemErro: e.toString(),
          brocas: brocas,
        );
      }
    }

    if (event is AlteraQuantidade) {
      if (event.quantidade == 0) return;
      if (event.quantidade <= event.brocas.length) {
        final brocas = event.brocas.sublist(0, event.quantidade);
        yield state.juntar(
          brocas: brocas,
          salvo: false,
          canas: brocas.length,
        );
      } else {
        final diferenca = event.quantidade - event.brocas.length;
        final brocaExemplo = state.primeiraBroca ?? event.brocas.first;
        int sequencia = event.brocas.length;

        final novasBrocas = List(diferenca)
            .map((_) => ApontBrocaModel(
                  instancia: brocaExemplo?.instancia,
                  noBoletim: brocaExemplo?.noBoletim,
                  noSequencia: ++sequencia,
                  dispositivo: brocaExemplo?.dispositivo,
                  cdFunc: brocaExemplo?.cdFunc,
                  cdFitoss: brocaExemplo?.cdFitoss,
                  cdSafra: brocaExemplo?.cdSafra,
                  cdUpnivel1: brocaExemplo?.cdUpnivel1,
                  cdUpnivel2: brocaExemplo?.cdUpnivel2,
                  cdUpnivel3: brocaExemplo?.cdUpnivel3,
                  dtOperacao: null,
                  dtStatus: null,
                  hrOperacao: null,
                  noColetor: brocaExemplo?.noColetor,
                  qtBrocados: 0,
                  qtCanas: 1,
                  qtCanaPodr: 0,
                  qtCanasbroc: 0,
                  qtEntrPodr: 0,
                  qtEntrenos: 0,
                  qtMedia: 0,
                  status: 'P',
                  versao: null,
                ))
            .toList();
        yield state.juntar(
          brocas: event.brocas + novasBrocas,
          canas: event.brocas.length + novasBrocas.length,
        );
      }
      try {
        await repositorioPreferencia.salvar(
          idPreferencia: 'quantidade-canas',
          valorPreferencia: event.quantidade,
        );
      } catch (e) {
        print(e);
        yield state.juntar(mensagemErro: e.toString());
      }
    }

    if (event is MarcaParaSalvar) {
      final brocas = state.brocas;
      brocas[event.broca.noSequencia - 1] = event.broca;

      yield state.juntar(salvo: false, brocas: brocas);
    }
  }
}