import 'dart:convert';
import 'package:agronomico/base/base_inherited.dart';
import 'package:agronomico/comum/modelo/estimativa_modelo.dart';
import 'package:agronomico/comum/modelo/upnivel3_model.dart';
import 'package:agronomico/comum/repositorios/upnivel3_consulta_repository.dart';
import 'package:agronomico/comum/repositorios/preferencia_repository.dart';
import 'package:agronomico/comum/repositorios/repositorio_estimativa.dart';
import 'package:agronomico/comum/repositorios/sequencia_repository.dart';
import 'package:agronomico/comum/utilidades/navegacao.dart';
import 'package:agronomico/paginas/apontamento_estimativa_form/apontamento_estimativa_page.dart';
import 'package:agronomico/paginas/upnivel3/upnivel3_event.dart';
import 'package:agronomico/paginas/upnivel3/upnivel3_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../comum/utilidades/navegacao.dart';

class UpNivel3Bloc extends Bloc<UpNivel3Event, UpNivel3State> {
  final UpNivel3ConsultaRepository upNivel3ConsultaRepository;
  final PreferenciaRepository preferenciaRepository;
  final RepositorioEstimativa estimativaRepository;
  final SincronizacaoSequenciaRepository sequenciaRepository;
  final Function({
    int cdFunc,
    int noBoletim,
    int dispositivo,
    List<UpNivel3Model> upniveis,
  }) callback;

  UpNivel3Bloc({
    @required this.upNivel3ConsultaRepository,
    @required this.preferenciaRepository,
    @required this.estimativaRepository,
    @required this.sequenciaRepository,
    @required this.callback,
  }) : super(UpNivel3State());

  @override
  Stream<UpNivel3State> mapEventToState(UpNivel3Event evento) async* {
    if (evento is AlterarFiltroUpNivel3) {
      final Map<String, dynamic> filtros = Map.from(state.filtros);

      if (evento.valor.isNotEmpty)
        filtros[evento.chave] = evento.valor;
      else
        filtros.remove(evento.chave);

      yield state.juntar(filtros: filtros);
    } else if (evento is BuscaListaUpNivel3) {
      try {
        yield state.juntar(
          carregando: true,
          lista: [],
          selecionadas: [],
        );

        final res = await upNivel3ConsultaRepository.get(
          filtros: _formataFiltros(evento.filtros),
        );

        if (evento.salvaFiltros)
          await preferenciaRepository.salvar(
            idPreferencia: 'upnivel3Filtros',
            valorPreferencia: json.encode(evento.filtros),
          );

        yield state.juntar(
          carregando: false,
          lista: res,
          filtros: evento.salvaFiltros ? state.filtros : evento.filtros,
        );
      } catch (e) {
        print(e);
        yield state.juntar(carregando: false, mensagemErro: e.toString());
      }
    } else if (evento is MudaSelecaoUpNivel3) {
      final List<UpNivel3Model> selecionadas = List.from(state.selecionadas);
      if (selecionadas.contains(evento.upnivel3)) {
        selecionadas.remove(evento.upnivel3);
      } else {
        selecionadas.add(evento.upnivel3);
      }
      yield state.juntar(selecionadas: selecionadas);
    } else if (evento is IniciarListaUpNivel3) {
      final Map<String, dynamic> filtros = json.decode(
          await preferenciaRepository.get(idPreferencia: 'upnivel3Filtros') ??
              '{}');
      final up2 = await upNivel3ConsultaRepository.buscaUp2();
      final listaDropDown = {
        'cdUpnivel2': up2,
      };

      filtros.keys.forEach((chave) {
        if (filtros[chave] != null && filtros[chave].toString().isNotEmpty) {
          listaDropDown[chave] = [filtros[chave]];
        }
      });

      yield state.juntar(
        filtros: filtros,
        listaDropDown: listaDropDown,
      );
    } else if (evento is BuscaSafra) {
      final listaDropDown = state.listaDropDown;
      final filtros = state.filtros;
      final safra = await upNivel3ConsultaRepository.buscaSafra(
        up1: evento.up1,
        up2: state.filtros['cdUpnivel2'],
      );
      listaDropDown['cdSafra'] = safra;
      yield state.juntar(listaDropDown: listaDropDown, filtros: {
        ...filtros,
        'cdUpnivel1': evento.up1,
        'cdSafra': '',
        'cdUpnivel3': '',
      });
    } else if (evento is BuscaUpnivel1) {
      final listaDropDown = state.listaDropDown;
      final filtros = state.filtros;
      final up1 = await upNivel3ConsultaRepository.buscaUp1(up2: evento.up2);
      listaDropDown['cdUpnivel1'] = up1;

      yield state.juntar(listaDropDown: listaDropDown, filtros: {
        ...filtros,
        'cdUpnivel2': evento.up2,
        'cdUpnivel1': '',
        'cdSafra': '',
        'cdUpnivel3': '',
      });
    } else if (evento is BuscaUpnivel3) {
      final listaDropDown = state.listaDropDown;
      final filtros = state.filtros;
      final up3 = await upNivel3ConsultaRepository.buscaUp3(
        safra: evento.safra,
        up1: state.filtros['cdUpnivel1'],
        up2: state.filtros['cdUpnivel2'],
      );
      listaDropDown['cdUpnivel3'] = up3;

      yield state.juntar(listaDropDown: listaDropDown, filtros: {
        ...filtros,
        'cdSafra': evento.safra,
        'cdUpnivel3': '',
      });
    } else if (evento is ConfirmaSelecaoUpNivel3) {
      try {
        final empresa = BaseInherited.of(
          evento.context,
        ).empresaAutenticada;

        final Map<String, dynamic> dispositivo = json.decode(
          await preferenciaRepository.get(idPreferencia: 'dispositivo'),
        );
        if (dispositivo == null) throw Exception('Dispositivo não cadastrado');

        final sequencia =
            await sequenciaRepository.buscarSequencia(empresa: empresa);
        int noSeqAtual = 0;

        final List<EstimativaModelo> estimativas = List();
        final cdFunc =
            BaseInherited.of(evento.context).usuarioAutenticada.cdFunc;
        String mensagemInicial;

        if (callback != null) {
          callback(
            cdFunc: cdFunc,
            dispositivo: dispositivo['idDispositivo'],
            upniveis: state.selecionadas,
          );
        } else {
          for (var item in state.selecionadas) {
            final existeEstimativa = await estimativaRepository.get(filtros: {
              'cdSafra': item.cdSafra,
              'cdUpnivel1': item.cdUpnivel1,
              'cdUpnivel2': item.cdUpnivel2,
              'cdUpnivel3': item.cdUpnivel3,
              'instancia': empresa.cdInstManfro,
            }).then((value) =>
                value.length > 0 && !value.every((item) => item.status == 'I'));

            if (existeEstimativa) {
              mensagemInicial =
                  'Existe estimativa não sincronizada para alguns registros. Efetue a sincronização!';
            } else {
              estimativas.add(item.gerarEstimativa(
                cdFunc: cdFunc,
                noSeq: ++noSeqAtual,
                noBoletim: 10000 + sequencia.sequencia + 1,
                dispositivo: dispositivo['idDispositivo'],
              ));
            }
          }

          navegar(
            context: evento.context,
            pagina: ApontamentoEstimativaPage(
              apontamentos: estimativas,
              criacao: true,
              mensagemInicial: mensagemInicial,
            ),
          );
        }
      } catch (e) {
        print(e);
        yield state.juntar(mensagemErro: e.toString());
      }
    } else if (evento is CheckAllUpNivel3) {
      if (!evento.valor) {
        yield state.juntar(selecionadas: []);
      } else {
        yield state.juntar(selecionadas: state.lista);
      }
    }
  }

  Map<String, dynamic> _formataFiltros(Map<String, dynamic> filtros) {
    final Map<String, dynamic> filtrosFormatados = Map.from(filtros);
    filtrosFormatados.removeWhere((chave, valor) => valor.isEmpty);
    filtrosFormatados.remove('dtInicio');
    filtrosFormatados.remove('dtFim');

    return filtrosFormatados;
  }
}
