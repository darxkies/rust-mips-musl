use core::fmt;
use core::pin::Pin;
use futures_core::future::{FusedFuture, Future};
use futures_core::stream::{FusedStream, Stream};
use futures_core::task::{Context, Poll};
use pin_project::{pin_project, project};

/// Future for the [`for_each`](super::StreamExt::for_each) method.
#[pin_project]
#[must_use = "futures do nothing unless you `.await` or poll them"]
pub struct ForEach<St, Fut, F> {
    #[pin]
    stream: St,
    f: F,
    #[pin]
    future: Option<Fut>,
}

impl<St, Fut, F> fmt::Debug for ForEach<St, Fut, F>
where
    St: fmt::Debug,
    Fut: fmt::Debug,
{
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ForEach")
            .field("stream", &self.stream)
            .field("future", &self.future)
            .finish()
    }
}

impl<St, Fut, F> ForEach<St, Fut, F>
where St: Stream,
      F: FnMut(St::Item) -> Fut,
      Fut: Future<Output = ()>,
{
    pub(super) fn new(stream: St, f: F) -> ForEach<St, Fut, F> {
        ForEach {
            stream,
            f,
            future: None,
        }
    }
}

impl<St, Fut, F> FusedFuture for ForEach<St, Fut, F>
    where St: FusedStream,
          F: FnMut(St::Item) -> Fut,
          Fut: Future<Output = ()>,
{
    fn is_terminated(&self) -> bool {
        self.future.is_none() && self.stream.is_terminated()
    }
}

impl<St, Fut, F> Future for ForEach<St, Fut, F>
    where St: Stream,
          F: FnMut(St::Item) -> Fut,
          Fut: Future<Output = ()>,
{
    type Output = ();

    #[project]
    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        #[project]
        let ForEach { mut stream, f, mut future } = self.project();
        loop {
            if let Some(fut) = future.as_mut().as_pin_mut() {
                ready!(fut.poll(cx));
                future.set(None);
            } else if let Some(item) = ready!(stream.as_mut().poll_next(cx)) {
                future.set(Some(f(item)));
            } else {
                break;
            }
        }
        Poll::Ready(())
    }
}
