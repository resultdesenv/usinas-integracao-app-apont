import 'dart:convert';

import 'package:agronomico/comum/modelo/safra_model.dart';
import 'package:agronomico/comum/modelo/sincronizacao_item_atualizacao_model.dart';
import 'package:agronomico/comum/repositorios/preferencia_repository.dart';
import 'package:agronomico/comum/repositorios/safra_repository.dart';
import 'package:agronomico/comum/sincronizacao/sincronizacao_autenticacao.dart';
import 'package:agronomico/comum/sincronizacao/sincronizacao_historico_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'sincronizacao.dart';

class SincronizacaoBloc extends Bloc<SincronizacaoEvent, SincronizacaoState> {
  final SincronizacaoHistoricoRepository sincronizacaoHistoricoRepository;
  final SincronizacaoAutenticacao sincronizacaoAutenticacao;
  final SafraRepository safraRepository;
  final PreferenciaRepository preferenciaRepository;

  SincronizacaoBloc({
    @required this.sincronizacaoHistoricoRepository,
    @required this.sincronizacaoAutenticacao,
    @required this.safraRepository,
    @required this.preferenciaRepository,
  }) : super(SincronizacaoState());

  @override
  Stream<SincronizacaoState> mapEventToState(SincronizacaoEvent event) async* {
    if (event is BuscarItensSincronizacao) {
      final historicoSincronizacao =
          await this.sincronizacaoHistoricoRepository.buscarHistorico();

      final itensSincronizacao = event.itensSincronizacao
          .map<HistoricoItemAtualizacaoModel>((itemSincronizacao) {
        final historico = historicoSincronizacao
            .where((e) => e.tabela == itemSincronizacao.tabela)
            .toList();

        final dataAtualizacao = historico.length == 0
            ? 'Sem historico de atualização'
            : historico[0].toText();
        return itemSincronizacao.copyWith(atualizacao: dataAtualizacao);
      }).toList();

      print(itensSincronizacao[itensSincronizacao.length - 1].upnivel3);

      final safras = await safraRepository.buscarSafras();

      final safraSelecionadaJson =
          await preferenciaRepository.get(idPreferencia: 'safra');

      SafraModel safraSelecionada;
      if (safraSelecionadaJson != null)
        safraSelecionada =
            SafraModel.fromJson(jsonDecode(safraSelecionadaJson));

      yield state.copyWith(
          itensSincronizacao: itensSincronizacao,
          safras: safras,
          safraSelecionada: safraSelecionada);
    }

    if (event is SincronizarItem) {
      try {
        final novaListaComLoading = state.itensSincronizacao.map((item) {
          if (item.tabela == event.historicoItemAtualizacaoModel.tabela)
            return item.copyWith(atualizando: true);
          return item;
        }).toList();

        yield state.copyWith(itensSincronizacao: novaListaComLoading);

        final token = await sincronizacaoAutenticacao.index();
        await event.historicoItemAtualizacaoModel.repository.index(token,
            cdInstManfro: event.empresaModel?.cdInstManfro,
            cdSafra: state.safraSelecionada?.cdSafra?.toString());

        final historicoAtualizacao =
            await sincronizacaoHistoricoRepository.buscarHistorico();

        final novaAtualizacao = historicoAtualizacao
            .firstWhere((item) =>
                item.tabela == event.historicoItemAtualizacaoModel.tabela)
            .toText();

        final novaListaSemLoading = novaListaComLoading.map((item) {
          if (item.tabela == event.historicoItemAtualizacaoModel.tabela)
            return item.copyWith(
                atualizando: false, atualizacao: novaAtualizacao);
          return item;
        }).toList();

        final safras = await safraRepository.buscarSafras();

        yield state.copyWith(
            itensSincronizacao: novaListaSemLoading, safras: safras);
      } catch (e) {
        yield state.copyWith(
            itensSincronizacao: state.itensSincronizacao
                .map((e) => e.copyWith(atualizando: false))
                .toList(),
            mensagem: e.toString());
      }
    }

    if (event is SincronizarTudo) {
      print('SincronizarTudo');
      for(final emp in event.itensSincronizacao) {
        try {
          final novaListaComLoading = state.itensSincronizacao.map((item) {
            if (item.tabela == emp.tabela)
              return item.copyWith(atualizando: true);
            return item;
          }).toList();

          yield state.copyWith(itensSincronizacao: novaListaComLoading);

          final token = await sincronizacaoAutenticacao.index();
          await emp.repository.index(token,
              cdInstManfro: event.empresaModel?.cdInstManfro,
              cdSafra: state.safraSelecionada?.cdSafra?.toString());

          final historicoAtualizacao =
          await sincronizacaoHistoricoRepository.buscarHistorico();

          final novaAtualizacao = historicoAtualizacao
              .firstWhere((item) =>
          item.tabela == emp.tabela)
              .toText();

          final novaListaSemLoading = novaListaComLoading.map((item) {
            if (item.tabela == emp.tabela)
              return item.copyWith(
                  atualizando: false, atualizacao: novaAtualizacao);
            return item;
          }).toList();

          final safras = await safraRepository.buscarSafras();

          yield state.copyWith(
              itensSincronizacao: novaListaSemLoading, safras: safras);
        } catch (e) {
          yield state.copyWith(
              itensSincronizacao: state.itensSincronizacao
                  .map((e) => e.copyWith(atualizando: false))
                  .toList(),
              mensagem: e.toString());
        }

      }
    }

    if (event is SelecionarSafra) {
      await preferenciaRepository.salvar(
          idPreferencia: 'safra',
          valorPreferencia: jsonEncode(event.safra.toJson()));
      yield state.copyWith(safraSelecionada: event.safra);
    }
  }
}
